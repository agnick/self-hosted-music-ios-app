import UIKit

enum AddToPlaylistAssembly {
    static func build(coreDataManager: CoreDataManager, userDefaultsManager: UserDefaultsManager, cloudAuthService: CloudAuthService) -> AddToPlaylistViewController {
        let presenter = AddToPlaylistPresenter()
        let worker = AddToPlaylistWorker(coreDataManager: coreDataManager, userDefaultsManager: userDefaultsManager)
        let interactor = AddToPlaylistInteractor(presenter: presenter, worker: worker, cloudAuthService: cloudAuthService)
        let viewFactory = AddToPlaylistViewFactory()
        let view = AddToPlaylistViewController(interactor: interactor, viewFactory: viewFactory)
        presenter.view = view
        
        return view
    }
}
