import UIKit

final class AudioImportPresenter: AudioImportPresentationLogic {
    // MARK: - Dependencies
    weak var view: AudioImportViewController?
    
    // MARK: - Public methods
    func presentFilePicker() {
        DispatchQueue.main.async {
            self.view?.displayFilePicker()
        }
    }
    
    func presentAuthAlert(_ response: AudioImportModel.AuthAlert.Response) {
        DispatchQueue.main.async {
            self.view?.displayAuthAlert(viewModel: AudioImportModel.AuthAlert.ViewModel(currentService: response.currentService, newService: response.newService))
        }
    }
    
    func presentError(_ response: AudioImportModel.Error.Response) {
        DispatchQueue.main.async {
            self.view?.displayError(viewModel: AudioImportModel.Error.ViewModel(errorDescription: response.error.localizedDescription))
        }
    }
    
    func routeToAudioFilesOverviewScreen(_ response: AudioImportModel.Route.Response) {
        DispatchQueue.main.async {
            self.view?.navigationController?.pushViewController(AudioFilesOverviewScreenAssembly.build(cloudDataService: response.cloudDataService, coreDataManager: response.coreDataManager, service: response.service), animated: true)
        }
    }
}
