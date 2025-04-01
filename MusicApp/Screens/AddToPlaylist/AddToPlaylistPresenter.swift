import UIKit

final class AddToPlaylistPresenter: AddToPlaylistPresentationLogic {
    // MARK: - Dependencies
    weak var view: AddToPlaylistViewController?
    
    // MARK: - Public methods
    func presentAudioFiles(_ request: AddToPlaylistModel.AudioFiles.Response) {
        DispatchQueue.main.async {
            self.view?.displayAudioFiles(AddToPlaylistModel.AudioFiles.ViewModel(filesCount: String(request.audioFiles.count), selectedFilesCount: String(request.selectedAudioFiles.count)))
        }
    }
    
    func presentPreLoading() {
        DispatchQueue.main.async {
            self.view?.displayPreLoading(AddToPlaylistModel.PreLoading.ViewModel(buttonsState: false))
        }
    }
    
    func presentTrackSelection(_ response: AddToPlaylistModel.TrackSelection.Response) {
        DispatchQueue.main.async {
            self.view?.displayTrackSelection(AddToPlaylistModel.TrackSelection.ViewModel(indexPath: response.indexPath, isSelected: response.selectedAudioFiles.count > 0, selectedAudioFilesCount: String(response.selectedAudioFiles.count)))
        }
    }
    
    func presentPickAll(_ response: AddToPlaylistModel.PickTracks.Response) {
        DispatchQueue.main.async {
            let buttonTitle = response.state ? "Выбрать все" : "Отменить"
            
            self.view?.displayPickAll(AddToPlaylistModel.PickTracks.ViewModel(buttonTitle: buttonTitle, state: response.state, selectedAudioFilesCount: String(response.selectedAudioFiles.count)))
        }
    }
    
    func presentSendSelectedTracks(_ response: AddToPlaylistModel.SendTracks.Response) {
        DispatchQueue.main.async {
            self.view?.delegate?.didSelectAudioFiles(response.selectedAudioFiles)
        }
    }
    
    func presentError(_ response: AddToPlaylistModel.Error.Response) {
        DispatchQueue.main.async {
            self.view?
                .displayError(
                    AddToPlaylistModel.Error
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
