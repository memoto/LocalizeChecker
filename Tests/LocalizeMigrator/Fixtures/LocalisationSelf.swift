import Foundation

struct Localisation {
}

struct Dog {
    static let localisation: Localisation.Type { Localisation.self }
    
    let name: String
    
    func voice() -> String {
        "Woof"
    }
}
