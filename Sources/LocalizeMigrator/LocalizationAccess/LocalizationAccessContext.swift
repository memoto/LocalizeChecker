import Foundation

struct LocalisationAccessContext {
    let localizeFuncName: String
    let namespace: String
    let firstLabel: String?
}

extension LocalisationAccessContext {
    
    static let `default`: Self = .init(
        localizeFuncName: "localized",
        namespace: "Localisation",
        firstLabel: "with"
    )
    
}
