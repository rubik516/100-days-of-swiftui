import SwiftUI

let USER_ADDRESS_KEY = "user_address"

@Observable
class Order: Codable {
    enum CodingKeys: String, CodingKey {
        case _type = "type"
        case _quantity = "quantity"
        case _specialRequestEnabled = "specialRequestEnabled"
        case _extraFrosting = "extraFrosting"
        case _addSprinkles = "addSprinkles"
        case _name = "name"
        case _city = "city"
        case _street = "street"
        case _zip = "zip"
    }
    
    static let types = ["Vanilla", "Strawberry", "Chocolate", "Rainbow"]
    
    var type = 0
    var quantity = 1
    
    var specialRequestEnabled = false {
        didSet {
            if specialRequestEnabled == false {
                extraFrosting = false
                addSprinkles = false
            }
        }
    }
    var extraFrosting = false
    var addSprinkles = false
    
    var address = [String: String]()
    var name = "" {
        didSet {
            saveAddress(for: "name")
        }
    }
    var street = "" {
        didSet {
            saveAddress(for: "street")
        }
    }
    var city = "" {
        didSet {
            saveAddress(for: "city")
        }
    }
    var zip = "" {
        didSet {
            saveAddress(for: "zip")
        }
    }
    
    init() {
        if let savedAddress = UserDefaults.standard.data(forKey: USER_ADDRESS_KEY) {
            if let decoded = try? JSONDecoder().decode([String: String].self, from: savedAddress) {
                name = decoded["name"] ?? ""
                street = decoded["street"] ?? ""
                city = decoded["city"] ?? ""
                zip = decoded["zip"] ?? ""
            }
        }
    }
    
    //    Cost function: https://www.hackingwithswift.com/books/ios-swiftui/preparing-for-checkout
    var cost: Decimal {
        // $2 per cake
        var cost = Decimal(quantity) * 2
        
        // complicated cakes cost more
        cost += Decimal(type) / 2
        
        // $1/cake for extra frosting
        if extraFrosting {
            cost += Decimal(quantity)
        }
        
        // $0.50/cake for sprinkles
        if addSprinkles {
            cost += Decimal(quantity) / 2
        }
        
        return cost
    }
    
    var hasInvalidAddress: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        street.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        zip.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func reset() {
        type = 0
        quantity = 1
        specialRequestEnabled = false
    }
    
    func saveAddress(for field: String) {
        switch field {
        case "name":
            address[field] = name
        case "street":
            address[field] = street
        case "city":
            address[field] = city
        case "zip":
            address[field] = zip
        default:
            return
        }
        
        if let encoded = try? JSONEncoder().encode(address) {
            UserDefaults.standard.set(encoded, forKey: USER_ADDRESS_KEY)
        }
    }
}
