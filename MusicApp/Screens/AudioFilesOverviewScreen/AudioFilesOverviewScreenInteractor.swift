//
//  AudioFilesOverviewScreenInteractor.swift
//  MusicApp
//
//  Created by Никита Агафонов on 07.01.2025.
//

import Foundation

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
    
    func downloadAudioFiles(_ request: AudioFilesOverviewScreenModel.DownloadAudio.Request) {
        let fileName = request.audioFile.name
        let url = request.audioFile.url
        let urlstring = url.absoluteString
        
        cloudAudioService.setDownloadingState(for: request.rowIndex, isDownloading: true)
        presenter.presentAudioFiles(AudioFilesOverviewScreenModel.FetchedFiles.Response(audioFiles: getAudioFiles()))
        
        Task {
            let urlFile = await cloudAudioService.downloadAudioFile(for : service, urlstring: urlstring, fileName: fileName)
            
            if let urlFile = urlFile {
                print(urlFile)
                presenter.presentDownloadedAudioFiles(AudioFilesOverviewScreenModel.DownloadAudio.Response(urlFile: urlFile))
            } else {
                presenter.presentError(AudioFilesOverviewScreenModel.Error.Response(error: NSError(domain: "Download error", code: 0)))
            }
        }
    }
    
    func downloadAllAudioFiles() {
        let audioFiles = getAudioFiles()
        for (index, audioFile) in audioFiles.enumerated() {
            let request = AudioFilesOverviewScreenModel.DownloadAudio.Request(audioFile: audioFile, rowIndex: index)
            downloadAudioFiles(request)
        }
    }
    
    func getAudioFiles() -> [AudioFile] {
        return cloudAudioService.getAudioFiles()
    }
}
