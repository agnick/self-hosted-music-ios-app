import UIKit

enum MyMusicAssembly {
    static func build(container: AppDIContainer) -> UIViewController {
        let presenter = MyMusicPresenter()
        let worker = MyMusicWorker(coreDataManager: container.coreDataManager)
        let interactor = MyMusicInteractor(presenter: presenter, worker: worker, cloudAuthService: container.cloudAuthService, cloudDataService: container.cloudDataService, audioPlayerService: container.audioPlayerService, userDefaultsManager: container.userDefaultsManager, coreDataManager: container.coreDataManager)
        let viewFactory = MyMusicViewFactory()
        let view = MyMusicViewController(interactor: interactor, viewFactory: viewFactory)
        presenter.view = view
        
        return view
    }
}
