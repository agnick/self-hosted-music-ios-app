//
//  AudioFilesOverviewScreenInteractor.swift
//  MusicApp
//
//  Created by Никита Агафонов on 07.01.2025.
//

final class AudioFilesOverviewScreenInteractor: AudioFilesOverviewScreenBusinessLogic {    
    // MARK: - Variables
    private let presenter: AudioFilesOverviewScreenPresentationLogic
    private let cloudAudioService: CloudAudioService
    private let service: CloudServiceType
    
    init (presenter: AudioFilesOverviewScreenPresentationLogic, cloudAudioService: CloudAudioService, service: CloudServiceType) {
        self.presenter = presenter
        self.cloudAudioService = cloudAudioService
        self.service = service
    }
    
    func fetchAudioFiles(_ request: AudioFilesOverviewScreenModel.FetchedFiles.Request) {
        cloudAudioService.fetchAudioFiles(for: service, forceRefresh: true) { [weak self] result in
            switch result {
            case .success:
                let audioFiles = self?.getAudioFiles()
                self?.presenter.presentAudioFiles(AudioFilesOverviewScreenModel.FetchedFiles.Response(audioFiles: audioFiles))
            case .failure(let error):
                self?.presenter.presentError(AudioFilesOverviewScreenModel.Error.Response(error: error))
            }
        }
    }
    
    func loadStart(_ request: AudioFilesOverviewScreenModel.Start.Request) {
        presenter.presentStart(AudioFilesOverviewScreenModel.Start.Response(service: service))
    }
    
    func getAudioFiles() -> [AudioFile] {
        return cloudAudioService.getAudioFiles()
    }
}
