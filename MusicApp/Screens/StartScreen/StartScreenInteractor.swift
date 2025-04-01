import Foundation

final class StartScreenInteractor: StartScreenBusinessLogic {
    // MARK: - Dependencies
    private let presenter: StartScreenPresentationLogic
    private let container: AppDIContainer
    
    // MARK: - Lifecycle
    init (presenter: StartScreenPresentationLogic, container: AppDIContainer) {
        self.presenter = presenter
        self.container = container
    }
    
    // MARK: - Navigation determination
    func loadMainScreen() {
        // Perform an asynchronous delay so as not to block the main thread and allow the UI to load.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard
                let self = self
            else {
                return
            }
            
            self.presenter.presentMainScreen(StartScreenModel.MainScreen.Response(container: container))
        }
    }
}
