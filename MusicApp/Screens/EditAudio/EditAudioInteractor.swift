import UIKit

final class EditAudioInteractor: EditAudioBusinessLogic {
    // MARK: - Dependencies
    private let presenter: EditAudioPresentationLogic
    private let worker: EditAudioWorkerProtocol
    private let audioPlayerService: AudioPlayerService
    
    // MARK: - States
    private var audioFile: AudioFile
    
    // MARK: - Lifecycle
    init (presenter: EditAudioPresentationLogic, worker: EditAudioWorkerProtocol, audioPlayerService: AudioPlayerService, audioFile: AudioFile) {
        self.presenter = presenter
        self.audioFile = audioFile
        self.audioPlayerService = audioPlayerService
        self.worker = worker
    }
    
    // MARK: - Public methods
    func loadStart() {
        presenter.presentStart(EditAudioModel.Start.Response(image: audioFile.trackImg, name: audioFile.name, artistName: audioFile.artistName))
    }
    
    func loadImagePicker() {
        presenter.presentImagePicker()
    }
    
    func loadPickedPlaylistImage(_ request: EditAudioModel.AudioImage.Request) {
        if let image = request.imageData as? UIImage {
            presenter.presentPickedPlaylistImage(EditAudioModel.AudioImage.Response(image: image))
            audioFile.trackImg = image
        } else {
            presenter.presentError(EditAudioModel.Error.Response(error: EditAudioError.imageDownloadError))
        }
    }
    
    func saveAudioFileChanges(_ request: EditAudioModel.EditData.Request) {
        audioFile.name = request.name
        audioFile.artistName = request.artistName
        audioFile.trackImg = request.image ?? UIImage(image: .icAudioImgSvg)
        
        do {
            try worker.updateAudioFileInCoreData(audioFile: audioFile)
        } catch {
            presenter.presentError(EditAudioModel.Error.Response(error: error))
        }
        
        audioPlayerService.updateCurrentTrack(with: audioFile)
    }
}
