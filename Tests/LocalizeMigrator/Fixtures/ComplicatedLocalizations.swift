
let plate = Plate(
    tools: [
        Localisation.fork,
        Localisation.knife,
        Localisation.spoon
    ],
    first: Localisation.tomatoSoup,
    second: Localisation.salmon
)

let emptyResultLabel = UILabel()
        .decorated(with: .headline5)
        .decorated(with: .alignment(.center))
        .decorated(with: .text(Localisation.common_no_results))
        .decorated(with: .hidden())

switch style {
case .welcome:
    return makeWelcomeScreen(actionTitle: Localisation.trading_stockreward_about_button)
case .about:
    return makeWelcomeScreen(actionTitle: Localisation.trading_stockreward_about_button2)
}

showAlert(
    title: Localisation.savings_plan_close_flow_alert_title,
    message: Localisation.savings_plan_close_flow_alert_message
)
