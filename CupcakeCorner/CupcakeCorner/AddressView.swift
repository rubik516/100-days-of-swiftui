import SwiftUI

struct AddressView: View {
    @Bindable var order: Order
    @Binding var path: NavigationPath
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $order.name)
                TextField("Street Address", text: $order.street)
                TextField("City", text: $order.city)
                TextField("Zip", text: $order.zip)
            }
            Section {
                NavigationLink("Check out", value: CHECKOUT_VIEW)
            }
            .disabled(order.hasInvalidAddress)
        }
        .navigationTitle("Delivery details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    @State var navigationPath = NavigationPath()
    return AddressView(order: Order(), path: $navigationPath)
}
