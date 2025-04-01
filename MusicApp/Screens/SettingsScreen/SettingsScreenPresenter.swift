import UIKit

final class SettingsScreenPresenter: SettingsScreenPresentationLogic {
    // MARK: - Dependencies
    weak var view: SettingsScreenViewController?
    
    // MARK: - Public methods
    func presentStart(_ request: SettingsScreenModel.Start.Response) {
        DispatchQueue.main.async {
            let cloudServiceName = request.cloudService?.rawValue ?? "Не подключено"
            
            var cloudServiceImage: UIImage?
            switch request.cloudService {
            case .dropbox:
                cloudServiceImage = UIImage(image: .icDropbox)
            case .googleDrive:
                cloudServiceImage = UIImage(image: .icGoogleDrive)
            default:
                break
            }
            
            let isConnected = request.cloudService != nil
            
            let viewModel = SettingsScreenModel.Start.ViewModel(
                cloudServiceName: cloudServiceName,
                cloudServiceImage: cloudServiceImage,
                appVersion: request.appVersion,
                freeMemoryGB: request.freeMemoryGB,
                usedMemoryGB: request.usedMemoryGB,
                isCloudServiceConnected: isConnected
            )

            self.view?.displayStart(viewModel)
        }
    }
    
    func presentError(_ response: SettingsScreenModel.Error.Response) {
        DispatchQueue.main.async {
            self.view?
                .displayError(
                    SettingsScreenModel.Error
                        .ViewModel(
                            errorDescription: response.error.localizedDescription
                        )
                )
        }
    }
    
    func routeTo() {
        view?.navigationController?.pushViewController(UIViewController(), animated: true)
    }
}
