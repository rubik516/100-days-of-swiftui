import SwiftUI

struct RoundButton: View {
    var label: String
    var onAction: () -> Void
    
    var body: some View {
        Button() {
            onAction()
        } label: {
            Text(label)
                .frame(width: 200, height: 200)
                .background(.black)
                .foregroundStyle(.white)
                .bold()
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
        }
    }
}

#Preview {
    func defaultAction() {
        print("RoundButton")
    }
    return RoundButton(label: "Label", onAction: defaultAction)
}
