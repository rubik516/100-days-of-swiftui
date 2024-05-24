import SwiftUI

enum ExpenseType: String, CaseIterable, Codable {
    case Business = "Business"
    case Personal = "Personal"
}

struct AddExpenseView: View {
    var expenses: Expenses
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var type = ExpenseType.Personal
    @State private var amount = 0.0
    
    @State private var showingDismissWarning = false
    @State private var hasUnsavedChanges = false
    
    func onDismiss() {
        if hasUnsavedChanges {
            showingDismissWarning = true
            return
        }
        dismiss()
        hasUnsavedChanges = false
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                    .onChange(of: name) {
                        hasUnsavedChanges = true
                    }
                
                Picker("Type", selection: $type) {
                    ForEach(ExpenseType.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .onChange(of: type) {
                    hasUnsavedChanges = true
                }
                
                TextField("Amount", value: $amount, format: .currency(code:PREFERRED_CURRENCY))
                    .keyboardType(.decimalPad)
                    .onChange(of: amount) {
                        hasUnsavedChanges = true
                    }
            }
            .navigationTitle("Add new expense")
            .alert("Discard changes?", isPresented: $showingDismissWarning) {
                Button("Continue", role: .destructive) {
                    dismiss()
                    hasUnsavedChanges = false
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close", role: .destructive) {
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let item = ExpenseItem(name: name, type: type, amount: amount)
                        expenses.items.append(item)
                        dismiss()
                    }
                }
            }
            .interactiveDismissDisabled(hasUnsavedChanges)
        }
    }
}

#Preview {
    AddExpenseView(expenses: Expenses())
}
