import UIKit

enum EditAudioAssembly {
    static func build(audioFile: AudioFile, coreDataManager: CoreDataManager) -> UIViewController {
        let presenter = EditAudioPresenter()
        let worker = EditAudioWorker(coreDataManager: coreDataManager)
        let audioPlayerService = AudioPlayerService()
        let interactor = EditAudioInteractor(presenter: presenter, worker: worker, audioPlayerService: audioPlayerService, audioFile: audioFile)
        let view = EditAudioViewController(interactor: interactor)
        presenter.view = view
        
        return view
    }
}
