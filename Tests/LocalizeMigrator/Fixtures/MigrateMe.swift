import Foundation

struct Localisation {
    static let greeting: String = ""
}

func setupButton() {
    button.configure(title: Localisation.greeting)
}

let title = Localisation.working_hours_banner_title
    .attributedString(font: .header, color: .c1)

let text = Localisation.news_tab_legal_note_full_text.trimCDATA()
