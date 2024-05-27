import SwiftUI

let USER_DEFAULTS_ITEMS_KEY = "Items"
let PREFERRED_CURRENCY = Locale.current.currency?.identifier ?? "CAD"

@Observable
class Expenses {
    var items: [ExpenseItem] {
        didSet {
            self.saveToUserDefaults()
        }
    }
    
    init() {
        items = [ExpenseItem]()
    }
    
    init(items: [ExpenseItem]) {
        self.items = items
    }
    
    func clearUserDefaults() {
        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS_ITEMS_KEY)
    }
    
    func loadFromUserDefaults() {
        if let savedItems = UserDefaults.standard.data(forKey: USER_DEFAULTS_ITEMS_KEY) {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }
        items = []
    }
    
    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: USER_DEFAULTS_ITEMS_KEY)
        }
    }
}

struct ExpensesSection: View {
    let header: String
    var expenses: Expenses
    let onRemoveExpenses: ([UUID]) -> Void
    
    @State private var itemsToRemove = [UUID]()
    
    func removeItems(at offsets: IndexSet) {
        offsets.forEach { index in
            itemsToRemove.append(expenses.items[index].id)
        }
        expenses.items.remove(atOffsets: offsets)
        onRemoveExpenses(itemsToRemove)
        itemsToRemove.removeAll()
    }
    
    var body: some View {
        Section(header) {
            if expenses.items.count == 0 {
                Text("No expenses have been recorded yet.")
                    .listRowBackground(Color(UIColor.systemGroupedBackground))
            } else {
                ForEach(expenses.items) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text(item.type.rawValue)
                        }
                        Spacer()
                        Text(item.amount, format: .currency(code: PREFERRED_CURRENCY))
                    }
                }
                .onDelete(perform: removeItems)
            }
        }
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()
    @State private var showingAddExpense = false
    @State private var showingClearExpenses = false
    
    var businessExpenses: [ExpenseItem] {
        expenses.items.filter {
            $0.type == ExpenseType.Business
        }
    }
    
    var personalExpenses: [ExpenseItem] {
        expenses.items.filter {
            $0.type == ExpenseType.Personal
        }
    }
    
    func updateRemovedExpenses(expenseIds: [UUID]) {
        expenses.items.removeAll(where: {expenseIds.contains($0.id)})
    }
    
    var body: some View {
        NavigationStack {
            List {
                ExpensesSection(
                    header: "Personal Expenses",
                    expenses: Expenses(items: personalExpenses),
                    onRemoveExpenses: updateRemovedExpenses
                )
                ExpensesSection(
                    header: "Business Expenses",
                    expenses: Expenses(items: businessExpenses),
                    onRemoveExpenses: updateRemovedExpenses
                )
            }
            .background(Color(UIColor.systemGroupedBackground))
            .toolbar {
                ToolbarItemGroup {
                    Button("Clear Expenses", systemImage: "trash") {
                        if expenses.items.count > 0 {
                            showingClearExpenses = true
                        }
                    }
                    Button("Add Expense", systemImage: "plus") {
                        showingAddExpense = true
                    }
                }
            }
            .navigationTitle("iExpense")
            .alert("Clear all expenses?", isPresented: $showingClearExpenses) {
                Button("Clear", role: .destructive) {
                    expenses.clearUserDefaults()
                    expenses.items = [ExpenseItem]()
                }
            } message: {
                Text("All expenses will be discarded. This action cannot be undone.")
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(expenses: expenses)
            }
            .onAppear() {
                expenses.loadFromUserDefaults()
            }
        }
    }
}

#Preview {
    ContentView()
}
