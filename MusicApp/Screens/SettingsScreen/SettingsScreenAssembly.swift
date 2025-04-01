import UIKit

enum SettingsScreenAssembly {
    static func build(container: AppDIContainer) -> UIViewController {
        let presenter = SettingsScreenPresenter()
        let interactor = SettingsScreenInteractor(presenter: presenter, cloudAuthService: container.cloudAuthService)
        let view = SettingsScreenViewController(interactor: interactor)
        presenter.view = view
        
        return view
    }
}
