import UIKit
import SwiftyDropbox

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    // DI start point.
    private let container = AppDIContainer()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Task.detached { [weak self] in
            await self?.reathorizeAllServices()
        }
        
        guard
            let windowScene = (scene as? UIWindowScene)
        else {
            return
        }
        
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .light
        window.rootViewController = UINavigationController(rootViewController: StartScreenAssembly.build(container: container))
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let oauthCompletion: DropboxOAuthCompletion = {
            if let authResult = $0 {
                switch authResult {
                case .success:
                    print("Success! User is logged into DropboxClientsManager.")
                    NotificationCenter.default.post(name: NSNotification.Name("DropboxAuthCompleted"), object: nil)
                case .cancel:
                    print("Authorization flow was manually canceled by user!")
                    NotificationCenter.default.post(name: NSNotification.Name("DropboxAuthCompleted"), object: nil, userInfo: ["error": "canceled"])
                case .error(_, let description):
                    print("Error: \(String(describing: description))")
                    NotificationCenter.default.post(name: NSNotification.Name("DropboxAuthCompleted"), object: nil, userInfo: ["error": description ?? "unknown error"])
                }
            }
        }
        
        for context in URLContexts {
            // stop iterating after the first handle-able url
            if DropboxClientsManager.handleRedirectURL(context.url, includeBackgroundClient: false, completion: oauthCompletion) { break }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    // MARK: - Private methods
    private func reathorizeAllServices() async {
        let cloudAuthService = container.cloudAuthService
        
        for service in RemoteAudioSource.allCases {
            do {
                print("Reauthorizing \(service)...")
                try await cloudAuthService.reauthorize(service)
                print("\(service) reauthorized successfully.")
            } catch {
                print(
                    "Failed to reauthorize \(service): \(error.localizedDescription)"
                )
            }
        }
    }
}
