import UIKit

final class EditAudioPresenter: EditAudioPresentationLogic {
    // MARK: - Dependencies
    weak var view: EditAudioViewController?
    
    // MARK: - Public methods
    func presentStart(_ response: EditAudioModel.Start.Response) {
        DispatchQueue.main.async {
            self.view?.displayStart(EditAudioModel.Start.ViewModel(image: response.image, name: response.name, artistName: response.artistName))
        }
    }
    
    func presentImagePicker() {
        DispatchQueue.main.async {
            self.view?.displayImagePicker()
        }
    }
    
    func presentPickedPlaylistImage(_ response: EditAudioModel.AudioImage.Response) {
        DispatchQueue.main.async {
            self.view?.displayPickedImage(EditAudioModel.AudioImage.ViewModel(image: response.image))
        }
    }
    
    func presentError(_ response: EditAudioModel.Error.Response) {
        DispatchQueue.main.async {
            print("Error: \(response.error.localizedDescription)")
            self.view?.displayError(EditAudioModel.Error.ViewModel(errorDescription: response.error.localizedDescription))
        }
    }
}

