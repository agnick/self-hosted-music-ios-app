import Foundation

final class AudioImportInteractor: AudioImportBusinessLogic {
    // MARK: - Dependencies
    private let presenter: AudioImportPresentationLogic
    private let worker: AudioImportWorkerProtocol
    private let cloudAuthService: CloudAuthService
    private let cloudDataService: CloudDataService
    private let coreDataManager: CoreDataManager
    
    // MARK: - Lifecycle
    init (
        presenter: AudioImportPresentationLogic,
        worker: AudioImportWorkerProtocol,
        cloudAuthService: CloudAuthService,
        cloudDataService: CloudDataService,
        coreDataManager: CoreDataManager
    ) {
        self.presenter = presenter
        self.worker = worker
        self.cloudAuthService = cloudAuthService
        self.cloudDataService = cloudDataService
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Public methods
    func handleCloudServiceSelection(
        _ request: AudioImportModel.CloudServiceSelection.Request
    ) {
        Task {
            do {
                if let current = cloudAuthService.currentService, current != request.service {
                    presenter.presentAuthAlert(AudioImportModel.AuthAlert.Response(currentService: current, newService: request.service))
                    
                    return
                }
                
                if cloudAuthService.currentService != request.service {
                    try await cloudAuthService.authorize(request.service, from: request.vc)
                }
                
                presenter.routeToAudioFilesOverviewScreen(AudioImportModel.Route.Response(cloudDataService: cloudDataService, coreDataManager: coreDataManager, service: request.service))
            } catch {
                presenter.presentError(AudioImportModel.Error.Response(error: error))
            }
        }
    }
    
    func newAuthorize(_ request: AudioImportModel.NewAuth.Request) {
        Task {
            do {
                try await cloudAuthService.logout(request.currentService)
                
                try await cloudAuthService.authorize(request.newService, from: request.vc)
                
                presenter.routeToAudioFilesOverviewScreen(AudioImportModel.Route.Response(cloudDataService: cloudDataService, coreDataManager: coreDataManager, service: request.newService))
            } catch {
                presenter.presentError(AudioImportModel.Error.Response(error: error))
            }
        }
    }
    
    func handleLocalFilesSelection() {
        presenter.presentFilePicker()
    }
    
    func copySelectedFilesToAppSupportFolder(_ request: AudioImportModel.LocalFiles.Request) {
        Task {
            do {
                try await worker.copyFilesToAppFolder(files: request.urls)
            } catch {
                presenter.presentError(AudioImportModel.Error.Response(error: error))
            }
        }
    }
}
