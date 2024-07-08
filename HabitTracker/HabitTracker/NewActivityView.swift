import SwiftUI

struct NewActivityView: View {
    private let activityManager = ActivityManager.getInstance()
    
    @State private var name = ""
    @State private var description = ""
    
    @State private var showingUnsavedChangesWarning = false
    
    @Environment(\.dismiss) var dismiss
    
    var hasUnsavedChanges: Bool {
        !name.isEmpty
    }
    
    func addActivity() {
        if !name.isEmpty {
            let activity = Activity(name: name.trimmingCharacters(in: .whitespacesAndNewlines), description: description.trimmingCharacters(in: .whitespacesAndNewlines))
            activityManager.add(activity: activity)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("E.g.: baking", text: $name)
                }
                Section("Description (optional)") {
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("E.g.: Baking once a week")
                                .opacity(0.2)
                                .padding(.top, 10)
                                .padding(.leading, 3)
                        }
                        TextEditor(text: $description)
                            .frame(minHeight: 96)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addActivity()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", role: .cancel) {
                        if hasUnsavedChanges {
                            showingUnsavedChangesWarning = true
                            return
                        }
                        dismiss()
                    }
                }
            }
            .alert("Discard changes?", isPresented: $showingUnsavedChangesWarning) {
                Button("Discard", role: .destructive) {
                    dismiss()
                }
                Button("Cancel", role: .cancel) {
                    showingUnsavedChangesWarning = false
                }
            }
            .interactiveDismissDisabled(hasUnsavedChanges)
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NewActivityView()
}
