
let plate = Plate(
    tools: [
        "fork".localized,
        "knife".localized,
        "spoon".localized
    ],
    first: "tomatoSoup".localized,
    second: "salmon".localized
)

let emptyResultLabel = UILabel()
        .decorated(with: .headline5)
        .decorated(with: .alignment(.center))
        .decorated(with: .text("common_no_results".localized))
        .decorated(with: .hidden())

switch style {
case .welcome:
    return makeWelcomeScreen(actionTitle: "trading_stockreward_about_button".localized)
case .about:
    return makeWelcomeScreen(actionTitle: "trading_stockreward_about_button2".localized)
}

showAlert(
    title: "savings_plan_close_flow_alert_title".localized,
    message: "savings_plan_close_flow_alert_message".localized
)
