import Foundation

struct Dog {
    let name: String
    
    func voice() -> String {
        "Woof"
    }
}

struct Names {
    static let top1 = "Rex"
}

let friend = Dog(name: Names.top1)
