import UIKit

enum PlayerAssembly {
    static func build(container: AppDIContainer) -> UIViewController {
        let presenter = PlayerPresenter()
        let worker = PlayerWorker(coreDataManager: container.coreDataManager)
        let interactor = PlayerInteractor(presenter: presenter, worker: worker, audioPlayerService: container.audioPlayerService, cloudDataService: container.cloudDataService, cloudAuthService: container.cloudAuthService, coreDataManager: container.coreDataManager)
        let viewFactory = PlayerViewFactory()
        let view = PlayerViewController(interactor: interactor, viewFactory: viewFactory)
        presenter.view = view
        
        return view
    }
}
