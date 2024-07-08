import SwiftUI

struct EmptyActivitiesView: View {
    var onAction: () -> Void
    
    var body: some View {
        VStack {
            Text("No habits to track yet.")
            
            VStack {
                Spacer()
                RoundButton(label: "Get Started") {
                    onAction()
                }
                Spacer()
            }
        }
    }
}

struct ContentView: View {
    private let activityManager = ActivityManager.getInstance()
    
    @State private var showingNewActivitySheet = false
    @State private var showingDiscardAlert = false
    
    var activities: [Activity] {
        activityManager.getActivities()
    }
    
    func removeActivity(at offsets: IndexSet) {
        offsets.forEach { index in
            activityManager.remove(activity: activities[index])
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if activityManager.hasNoActivities() {
                    EmptyActivitiesView {
                        showingNewActivitySheet.toggle()
                    }
                } else {
                    List {
                        ForEach(activities) { activity in
                            NavigationLink {
                                ActivityDetailsView(activity: activity)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(activity.name)
                                        .bold()
                                    HStack {
                                        Text("Completed:")
                                        Text("\(activity.count) times")
                                    }
                                }
                            }
                        }
                        .onDelete(perform: removeActivity)
                    }
                }
            }
            .alert("Discard all habits?", isPresented: $showingDiscardAlert) {
                Button("Discard", role: .destructive) {
                    activityManager.clearAllActivities()
                    
                }
                Button("Cancel", role: .cancel) {
                    showingDiscardAlert = false
                }
            } message: {
                Text("This action cannot be undone.")
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add", systemImage: "plus") {
                        showingNewActivitySheet.toggle()
                    }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Clear", systemImage: "trash") {
                        if activities.count > 0 {
                            showingDiscardAlert = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showingNewActivitySheet) {
                NewActivityView()
            }
            .navigationTitle("Habit Tracker")
        }
    }
}

#Preview {
    ContentView()
}
