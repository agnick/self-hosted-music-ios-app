import UIKit

final class StartScreenPresenter: StartScreenPresentationLogic {
    // MARK: - Dependencies
    weak var view: StartScreenViewController?
    
    // MARK: - Public methods
    func presentMainScreen(_ response: StartScreenModel.MainScreen.Response) {
        // Replaces the rootViewController to prevent returning to the start screen.
        // Ensures proper navigation flow on subsequent screens.
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else {
            return
        }
        
        window.rootViewController = TabViewController(container: response.container)
        window.makeKeyAndVisible()
    }
}
