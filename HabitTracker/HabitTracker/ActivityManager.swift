import Foundation

let SAVED_ACTIVITIES_USER_DEFAULTS_KEY = "SavedActivities"

struct Activity: Identifiable, Codable {
    var id: UUID
    var name: String
    var description: String
    var count = 0
    
    init(name: String, description: String, id: UUID = UUID()) {
        self.id = id
        self.name = name
        self.description = description
    }
    
    mutating func incrementCount() {
        self.count += 1
    }
}

@Observable
class ActivityManager {
    private static var instance = ActivityManager()
    private var activities = [UUID: Activity]() {
        didSet {
            saveToUserDefaults()
        }
    }
    
    private init() {
        if let savedActivities = UserDefaults.standard.data(forKey: SAVED_ACTIVITIES_USER_DEFAULTS_KEY) {
            if let decoded = try? JSONDecoder().decode([UUID: Activity].self, from: savedActivities) {
                activities = decoded
                return
            }
        }
        activities = [UUID: Activity]()
    }
    
    static func getInstance() -> ActivityManager {
        return instance
    }
    
    func add(activity: Activity) {
        activities[activity.id] = activity
    }
    
    func clearAllActivities() {
        activities.removeAll()
        clearUserDefaults()
    }
    
    func getActivities() -> [Activity] {
        Array(activities.values).sorted { lhs, rhs in
            lhs.name < rhs.name
        }
    }
    
    func hasNoActivities() -> Bool {
        activities.count == 0
    }
    
    func remove(activity: Activity) {
        activities.removeValue(forKey: activity.id)
    }
    
    func updateActivity(for activity: Activity) {
        activities[activity.id] = activity
        saveToUserDefaults()
    }
    
    private func clearUserDefaults() {
        UserDefaults.standard.removeObject(forKey: SAVED_ACTIVITIES_USER_DEFAULTS_KEY)
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(encoded, forKey: SAVED_ACTIVITIES_USER_DEFAULTS_KEY)
        }
    }
}
