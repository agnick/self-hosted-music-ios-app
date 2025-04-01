import UIKit

protocol EditAudioBusinessLogic {
    func loadStart()
    func loadImagePicker()
    func loadPickedPlaylistImage(_ request: EditAudioModel.AudioImage.Request)
    func saveAudioFileChanges(_ request: EditAudioModel.EditData.Request)
}

protocol EditAudioPresentationLogic {
    func presentStart(_ response: EditAudioModel.Start.Response)
    func presentImagePicker()
    func presentPickedPlaylistImage(_ response: EditAudioModel.AudioImage.Response)
    func presentError(_ response: EditAudioModel.Error.Response)
}

protocol EditAudioWorkerProtocol {
    func updateAudioFileInCoreData(audioFile: AudioFile) throws
}
