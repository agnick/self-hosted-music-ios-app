import UIKit

enum AudioImportAssembly {
    static func build(сontainer: AppDIContainer) -> UIViewController {
        let presenter = AudioImportPresenter()
        let worker = AudioImportWorker(coreDataManager: сontainer.coreDataManager)
        let interactor = AudioImportInteractor(
            presenter: presenter,
            worker: worker,
            cloudAuthService: сontainer.cloudAuthService,
            cloudDataService: сontainer.cloudDataService,
            coreDataManager: сontainer.coreDataManager
        )
        let view = AudioImportViewController(interactor: interactor)
        presenter.view = view
        
        return view
    }
}
