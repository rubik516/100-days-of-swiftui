import SwiftUI

struct ContentView: View {
    let currency = Locale.current.currency?.identifier ?? "CAD"
    let currencySymbol = Locale.current.currencySymbol ?? "$"
    let tipPercentages = [0, 10, 15, 20, -1]
    
    @State private var billAmount = 0.0
    
    @State private var numberOfPeople = 2
    @State private var customNumberOfPeople = 1
    
    @State private var selectedTipPercentage = 20
    @State private var customTip = 0
    
    @FocusState private var isbillAmountFocused: Bool
    @FocusState private var isNumberOfPeopleFocused: Bool
    @FocusState private var isCustomTipFocused: Bool
    
    var totalAmount: Double {
        billAmount + totalTip
    }
    
    var totalPeople: Int {
        numberOfPeople == 0 ? customNumberOfPeople : numberOfPeople
    }
    
    var totalPerPerson: Double {
        totalAmount / Double(totalPeople)
    }
    
    var totalTip: Double {
        let tip = selectedTipPercentage == -1 ? customTip : selectedTipPercentage
        return billAmount * Double(tip) / 100
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Enter your bill's amount") {
                    TextField("E.g.: \(currencySymbol)32.50", value: $billAmount, format: .currency(code: currency))
                        .keyboardType(.decimalPad)
                        .focused($isbillAmountFocused)
                }
                Section("How many people will share this bill?") {
                    Picker("How many people", selection: $numberOfPeople) {
                        ForEach(0...10, id: \.self) { numPeople in
                            if numPeople == 0 {
                                Text("Other")
                            } else {
                                Text("\(numPeople) people")
                            }
                        }
                    }
                    if numberOfPeople == 0 {
                        TextField("E.g.: 2", value: $customNumberOfPeople, format: .number)
                            .keyboardType(.numberPad)
                            .focused($isNumberOfPeopleFocused)
                    }
                }
                Section("How much do you want to tip") {
                    Picker("How much do you want to tip", selection: $selectedTipPercentage) {
                        ForEach(tipPercentages, id: \.self) { tip in
                            if (tip != -1) {
                                Text(tip, format: .percent)
                            } else {
                                Text("Custom")
                            }
                        }
                    }
                    .pickerStyle(.segmented)
                    if selectedTipPercentage == -1 {
                        TextField("E.g.: 12", value: $customTip, format: .percent)
                            .keyboardType(.numberPad)
                            .focused($isCustomTipFocused)
                    }
                }
                Section("Total tip") {
                    Text(totalTip, format: .currency(code: currency))
                }
                Section("Total amount") {
                    Text(totalAmount, format: .currency(code: currency))
                }
                Section("Amount per person") {
                    if totalPeople == 0 {
                        Text("This bill is shared among 0 people. You may have been treated for this meal, or there may be a mistake somewhere...")
                    } else {
                        Text(totalPerPerson, format: .currency(code: currency))
                    }
                }
            }
            .navigationTitle("Bill details")
            .navigationBarTitleDisplayMode(/*@START_MENU_TOKEN@*/.automatic/*@END_MENU_TOKEN@*/)
            .toolbar {
                if isbillAmountFocused {
                    Button("Done") {
                        isbillAmountFocused = false
                    }
                }
                if isNumberOfPeopleFocused {
                    Button("Done") {
                        isNumberOfPeopleFocused = false
                    }
                }
                if isCustomTipFocused {
                    Button("Done") {
                        isCustomTipFocused = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
