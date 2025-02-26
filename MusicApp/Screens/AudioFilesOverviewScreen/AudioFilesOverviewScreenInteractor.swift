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
        Task {
            do {
                let audioFiles = try await cloudAudioService.fetchAudioFiles(for: service, forceRefresh: true)
                presenter.presentAudioFiles(AudioFilesOverviewScreenModel.FetchedFiles.Response(audioFiles: audioFiles))
            } catch {
                presenter.presentError(AudioFilesOverviewScreenModel.Error.Response(error: error))
            }
        }
    }
    
    func loadStart(_ request: AudioFilesOverviewScreenModel.Start.Request) {
        presenter.presentStart(AudioFilesOverviewScreenModel.Start.Response(service: service))
    }
    
    func downloadAudioFiles(_ request: AudioFilesOverviewScreenModel.DownloadAudio.Request) {
        let fileName = request.audioFile.name
        let source = request.audioFile.downloadPath
        
        cloudAudioService.setDownloadingState(for: request.rowIndex, downloadState: .downloading)
        presenter.presentAudioFiles(AudioFilesOverviewScreenModel.FetchedFiles.Response(audioFiles: getAudioFiles()))
        
        Task {
            do {
                let isDownloaded = try await cloudAudioService.downloadAudioFile(for: service, from: source, fileName: fileName)
                cloudAudioService.setDownloadingState(for: request.rowIndex, downloadState: isDownloaded ? .downloaded : .failed)
                presenter.presentDownloadedAudioFiles(AudioFilesOverviewScreenModel.DownloadAudio.Response(fileName: fileName, isDownloaded: isDownloaded))
            } catch {
                presenter.presentError(AudioFilesOverviewScreenModel.Error.Response(error: error))
            }
        }
    }
    
    func downloadAllAudioFiles() {
        Task {
            let audioFiles = getAudioFiles()
            for (index, audioFile) in audioFiles.enumerated() {
                let request = AudioFilesOverviewScreenModel.DownloadAudio.Request(audioFile: audioFile, rowIndex: index)
                
                downloadAudioFiles(request)
            }
        }
    }
    
    func getAudioFiles() -> [AudioFile] {
        return cloudAudioService.getAudioFiles()
    }
}
