import UIKit

enum AudioFilesOverviewScreenAssembly {
    static func build(cloudDataService: CloudDataService, coreDataManager: CoreDataManager, service: RemoteAudioSource) -> UIViewController {
        let presenter = AudioFilesOverviewScreenPresenter()
        let worker = AudioFilesOverviewScreenWorker(coreDataManager: coreDataManager)
        let interactor = AudioFilesOverviewScreenInteractor(presenter: presenter, worker: worker, cloudDataService: cloudDataService, service: service)
        let view = AudioFilesOverviewScreenViewController(interactor: interactor)
        presenter.view = view
        
        return view
    }
}
