import UIKit

enum StartScreenAssembly {
    static func build(container: AppDIContainer) -> UIViewController {
        let presenter = StartScreenPresenter()
        let interactor = StartScreenInteractor(presenter: presenter, container: container)
        let view = StartScreenViewController(interactor: interactor)
        presenter.view = view
        
        return view
    }
}
