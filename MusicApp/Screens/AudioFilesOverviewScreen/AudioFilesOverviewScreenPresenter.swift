import UIKit

final class AudioFilesOverviewScreenPresenter: AudioFilesOverviewScreenPresentationLogic {
    // MARK: - Dependencies
    weak var view: AudioFilesOverviewScreenViewController?
    
    // MARK: - Public methods
    func presentStart(
        _ response: AudioFilesOverviewScreenModel.Start.Response
    ) {
        DispatchQueue.main.async {
            let serviceName = response.service.rawValue
            self.view?
                .displayStart(
                    AudioFilesOverviewScreenModel.Start
                        .ViewModel(serviceName: serviceName)
                )
        }
    }
    
    func presentError(
        _ response: AudioFilesOverviewScreenModel.Error.Response
    ) {
        DispatchQueue.main.async {
            self.view?.displayError(AudioFilesOverviewScreenModel.Error.ViewModel(errorDescription: response.error.localizedDescription))
        }
    }
    
    func presentAudioFiles(
        _ response: AudioFilesOverviewScreenModel.FetchedFiles.Response
    ) {
        DispatchQueue.main.async {
            let audioFilesCount = response.audioFiles?.count ?? 0
            self.view?.displayAudioFiles(
                AudioFilesOverviewScreenModel.FetchedFiles
                    .ViewModel(audioFilesCount: audioFilesCount, isUserInitiated: response.isUserInitiated)
            )
        }
    }
    
    func presentDownloadedAudioFiles(
        _ response: AudioFilesOverviewScreenModel.DownloadAudio.Response
    ) {
        DispatchQueue.main.async {
            self.view?
                .displayDownloadAudio(
                    AudioFilesOverviewScreenModel.DownloadAudio
                        .ViewModel(fileName: response.fileName, isDownloaded: response.isDownloaded)
                )
        }
    }
}
