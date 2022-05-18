import Foundation

struct Localisation {
    static func report_health(_ age: Int, _ height: Int) -> String {
        ""
    }
    static thanks: String = ""
}

func setupButton() {
    let age = 33
    let height = 182
    let result = "\("report_health".localized(with: age, height)) and also \("thanks".localized)"
}
