import UIKit

final class NewPlaylistPresenter: NewPlaylistPresentationLogic {
    // MARK: - Dependencies
    weak var view: NewPlaylistViewController?
    
    // MARK: - Public methods
    func presentCellData(_ response: NewPlaylistModel.CellData.Response) {
        DispatchQueue.main.async {
            var source: RemoteAudioSource? = nil
            
            if let remote = response.audioFile as? RemoteAudioFile {
                source = remote.source
            }
            
            let viewModel = NewPlaylistModel.CellData.ViewModel(index: response.index, name: response.audioFile.name, artistName: response.audioFile.artistName, image: response.audioFile.trackImg, durationInSeconds: response.audioFile.durationInSeconds, source: source)
            
            self.view?.displayCellData(viewModel)
        }
    }
    
    func presentSelectedTracks() {
        DispatchQueue.main.async {
            self.view?.displaySelectedTracks()
        }
    }
    
    func presentImagePicker() {
        DispatchQueue.main.async {
            self.view?.displayImagePicker()
        }
    }
    
    func presentPickedPlaylistImage(_ response: NewPlaylistModel.PlaylistImage.Response) {
        DispatchQueue.main.async {
            self.view?.displayPickedImage(NewPlaylistModel.PlaylistImage.ViewModel(image: response.imageData))
        }
    }
    
    func presentError(_ response: NewPlaylistModel.Error.Response) {
        DispatchQueue.main.async {
            self.view?.displayError(NewPlaylistModel.Error.ViewModel(errorDescription: response.error.localizedDescription))
        }
    }
    
    func presentPlaylistSavedSuccessfully() {
        DispatchQueue.main.async {
            self.view?.navigationController?.popViewController(animated: true)
        }
    }
    
    func routeTo(vc: UIViewController) {
        view?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getAddToPlaylistDelegate() -> AddToPlaylistDelegate? {
        return view
    }
}
