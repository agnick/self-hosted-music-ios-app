import Foundation

final class AudioFilesOverviewScreenInteractor: AudioFilesOverviewScreenBusinessLogic, AudioFilesOverviewScreenDataStore {
    // MARK: - Dependencies
    private let presenter: AudioFilesOverviewScreenPresentationLogic
    private let worker: AudioFilesOverviewScreenWorkerProtocol
    private let cloudDataService: CloudDataService
    private let service: RemoteAudioSource
    
    // MARK: - States
    var audioFiles: [RemoteAudioFile] = []
    
    // MARK: - Lifecycle
    init (presenter: AudioFilesOverviewScreenPresentationLogic, worker: AudioFilesOverviewScreenWorkerProtocol, cloudDataService: CloudDataService, service: RemoteAudioSource) {
        self.presenter = presenter
        self.worker = worker
        self.cloudDataService = cloudDataService
        self.service = service
    }
    
    // MARK: - Start
    func loadStart() {
        presenter.presentStart(AudioFilesOverviewScreenModel.Start.Response(service: service))
    }
    
    // MARK: - Fetch
    func fetchAudioFiles() {
        Task {
            do {
                let cached = try worker.fetchAudioFilesFromStorage(for: service)
                
                if !cached.isEmpty {
                    self.audioFiles = cached
                    presenter.presentAudioFiles(AudioFilesOverviewScreenModel.FetchedFiles.Response(audioFiles: cached, isUserInitiated: true))
                    return
                }
                
                let fetched = try await cloudDataService.fetchFiles()
                self.audioFiles = fetched
                
                presenter.presentAudioFiles(AudioFilesOverviewScreenModel.FetchedFiles.Response(audioFiles: fetched, isUserInitiated: true))
            } catch {
                presenter.presentError(AudioFilesOverviewScreenModel.Error.Response(error: error))
            }
        }
    }
    
    func refreshAudioFiles() {
        Task {
            do {
                let fetched = try await cloudDataService.fetchFiles()
                self.audioFiles = fetched
                presenter.presentAudioFiles(AudioFilesOverviewScreenModel.FetchedFiles.Response(audioFiles: fetched, isUserInitiated: true))
            } catch {
                presenter.presentError(AudioFilesOverviewScreenModel.Error.Response(error: error))
            }
        }
    }
    
    // MARK: - Download single
    func downloadAudioFiles(_ request: AudioFilesOverviewScreenModel.DownloadAudio.Request) {
        let index = request.rowIndex
        
        guard index < audioFiles.count else {
            return
        }
        
        // Mark as downloading.
        var file = audioFiles[index]
        file.downloadState = .downloading
        audioFiles[index] = file
        
        presenter.presentAudioFiles(AudioFilesOverviewScreenModel.FetchedFiles.Response(audioFiles: audioFiles, isUserInitiated: false))
        
        // Downloading process.
        Task {
            do {
                _ = try await cloudDataService.download(file)
                                
                file.downloadState = .downloaded
                audioFiles[index] = file
                
                presenter.presentDownloadedAudioFiles(AudioFilesOverviewScreenModel.DownloadAudio.Response(fileName: file.name, isDownloaded: true))
            } catch {
                file.downloadState = .failed
                audioFiles[index] = file
                presenter.presentError(AudioFilesOverviewScreenModel.Error.Response(error: error))
                
                presenter.presentAudioFiles(AudioFilesOverviewScreenModel.FetchedFiles.Response(audioFiles: audioFiles, isUserInitiated: false))
            }
        }
    }
    
    // MARK: - Download all
    func downloadAllAudioFiles() {
        for (idx, file) in audioFiles.enumerated() {
            downloadAudioFiles(AudioFilesOverviewScreenModel.DownloadAudio.Request(audioFile: file, rowIndex: idx))
        }
    }
}
