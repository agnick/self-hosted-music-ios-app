import UIKit

enum NewPlaylistAssembly {
    static func buildCreate(coreDataManager: CoreDataManager, userDefaultsManager: UserDefaultsManager, cloudAuthService: CloudAuthService) -> UIViewController {
        return build(
            mode: .create,
            coreDataManager: coreDataManager,
            userDefaultsManager: userDefaultsManager,
            cloudAuthService: cloudAuthService
        )
    }

    static func buildEdit(playlist: Playlist, coreDataManager: CoreDataManager, userDefaultsManager: UserDefaultsManager, cloudAuthService: CloudAuthService) -> UIViewController {
        return build(
            mode: .edit(playlist),
            coreDataManager: coreDataManager,
            userDefaultsManager: userDefaultsManager,
            cloudAuthService: cloudAuthService
        )
    }

    private static func build(mode: PlaylistEditingMode, coreDataManager: CoreDataManager, userDefaultsManager: UserDefaultsManager, cloudAuthService: CloudAuthService) -> UIViewController {
        let presenter = NewPlaylistPresenter()
        let worker = NewPlaylistWorker(coreDataManager: coreDataManager)
        let interactor = NewPlaylistInteractor(mode: mode, presenter: presenter, worker: worker, coreDataManager: coreDataManager, userDefaultsManager: userDefaultsManager, cloudAuthService: cloudAuthService)
        let view = NewPlaylistViewController(mode: mode, interactor: interactor)
        presenter.view = view

        return view
    }
}
