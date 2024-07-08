import SwiftUI

struct ActivityDetailsView: View {
    @State var activity: Activity
    private let activityManager = ActivityManager.getInstance()
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(activity.name)
                        .font(.largeTitle)
                        .bold()
                    if !activity.description.isEmpty {
                        Text(activity.description)
                            .foregroundStyle(.gray)
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            
            VStack {
                Spacer()
                
                VStack {
                    RoundButton(label: "Log completion") {
                        activity.incrementCount()
                        activityManager.updateActivity(for: activity)
                    }
                    HStack {
                        Text("Completed:")
                        Text("\(activity.count) times")
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    let defaultActivity = Activity(name: "Default Activity", description: "Default Description")
    return ActivityDetailsView(activity: defaultActivity)
}
