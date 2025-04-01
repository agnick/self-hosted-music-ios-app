import UIKit

enum PlaylistAssembly {
    static func build(playlist: Playlist, coreDataManager: CoreDataManager, cloudDataService: CloudDataService, audioPlayerService: AudioPlayerService, userDefaultsManager: UserDefaultsManager, cloudAuthService: CloudAuthService) -> UIViewController {
        let presenter = PlaylistPresenter()
        let userDefaultsManager = UserDefaultsManager()
        let worker = PlaylistWorker(coreDataManager: coreDataManager, userDefaultsManager: userDefaultsManager)
        let interactor = PlaylistInteractor(playlist: playlist, presenter: presenter, worker: worker, coreDataManager: coreDataManager, cloudDataService: cloudDataService, audioPlayerService: audioPlayerService, userDefaultsManager: userDefaultsManager, cloudAuthService: cloudAuthService)
        let viewFactory = PlaylistViewFactory()
        let view = PlaylistViewController(interactor: interactor, viewFactory: viewFactory)
        presenter.view = view
        
        return view
    }
}
