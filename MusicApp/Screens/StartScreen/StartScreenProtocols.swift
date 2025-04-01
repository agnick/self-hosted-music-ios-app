protocol StartScreenBusinessLogic {
    func loadMainScreen()
}

protocol StartScreenPresentationLogic {
    func presentMainScreen(_ response: StartScreenModel.MainScreen.Response)
}
