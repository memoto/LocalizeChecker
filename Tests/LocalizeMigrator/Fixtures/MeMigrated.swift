import Foundation

struct Localisation {
    static let greeting: String = ""
}

func setupButton() {
    button.configure(title: "greeting".localized)
}

let title = "working_hours_banner_title".localized
    .attributedString(font: .header, color: .c1)

let text = "news_tab_legal_note_full_text".localized.trimCDATA()
