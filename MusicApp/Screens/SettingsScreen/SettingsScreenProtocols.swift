protocol SettingsScreenBusinessLogic {
    func loadStart()
    func logoutFromCloudService()
}

protocol SettingsScreenPresentationLogic {
    func presentStart(_ response: SettingsScreenModel.Start.Response)
    func presentError(_ response: SettingsScreenModel.Error.Response)
    
    func routeTo()
}
