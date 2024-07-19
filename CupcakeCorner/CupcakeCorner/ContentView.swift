import SwiftUI

let ADDRESS_VIEW = "AddressView"
let CHECKOUT_VIEW = "CheckoutView"

struct ContentView: View {
    @State private var path = NavigationPath()
    @State private var order = Order()
    
    var body: some View {
        NavigationStack(path: $path) {
            Form {
                Section {
                    Picker("Select cake type: ", selection: $order.type) {
                        ForEach(Order.types.indices, id: \.self) {
                            Text(Order.types[$0])
                        }
                    }
                    Stepper("Number of cakes: \(order.quantity)", value: $order.quantity, in: 1...20)
                }
                
                Section {
                    Toggle("Any special requests?", isOn: $order.specialRequestEnabled)
                    if order.specialRequestEnabled {
                        Toggle("Extra frosting", isOn: $order.extraFrosting)
                        Toggle("Extra sprinkles", isOn: $order.addSprinkles)
                    }
                }
                
                Section {
                    NavigationLink("Delivery Details", value: ADDRESS_VIEW)
                }
                .navigationDestination(for: String.self) { value in
                    if value == ADDRESS_VIEW {
                        AddressView(order: order, path: $path)
                    }
                    else if value == CHECKOUT_VIEW {
                        CheckoutView(order: order, path: $path)
                    }
                }
            }
            .navigationTitle("Cupcake Corner")
        }
    }
}

#Preview {
    ContentView()
}
