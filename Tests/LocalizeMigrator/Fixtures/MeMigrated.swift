import Foundation

struct Localisation {
    static let greeting: String = ""
}

func setupButton() {
    button.configure(title: "greeting".localized)
}
