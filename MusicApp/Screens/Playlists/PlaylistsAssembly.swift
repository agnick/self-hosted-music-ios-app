import UIKit

enum PlaylistsAssembly {
    static func build(container: AppDIContainer) -> UIViewController {
        let presenter = PlaylistsPresenter()
        let worker = PlaylistsWorker(coreDataManager: container.coreDataManager)
        let interactor = PlaylistsInteractor(presenter: presenter, worker: worker, coreDataManager: container.coreDataManager, userDefaultsManager: container.userDefaultsManager, cloudAuthService: container.cloudAuthService, cloudDataService: container.cloudDataService, audioPlayerService: container.audioPlayerService)
        let view = PlaylistsViewController(interactor: interactor)
        presenter.view = view
        
        return view
    }
}
