import CoreMedia

final class PlayerInteractor: PlayerBusinessLogic {
    // MARK: - Dependencies
    private let presenter: PlayerPresentationLogic
    private let worker: PlayerWorkerProtocol
    private let audioPlayerService: AudioPlayerService
    private let cloudDataService: CloudDataService
    private let cloudAuthService: CloudAuthService
    private let coreDataManager: CoreDataManager
        
    // MARK: - Lifecycle
    init (presenter: PlayerPresentationLogic, worker: PlayerWorkerProtocol, audioPlayerService: AudioPlayerService, cloudDataService: CloudDataService, cloudAuthService: CloudAuthService, coreDataManager: CoreDataManager) {
        self.presenter = presenter
        self.worker = worker
        self.audioPlayerService = audioPlayerService
        self.cloudDataService = cloudDataService
        self.cloudAuthService = cloudAuthService
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Public methods
    func loadStart() {
        if let currentTrack = audioPlayerService.getCurrentTrack() {
            let currentTime = audioPlayerService.getCurrentTime()
            
            presenter.presentStart(PlayerModel.Start.Response(currentTrack: currentTrack, currentTime: currentTime))
            loadPlayPauseState()
            loadRepeatState()
        }
    }
    
    func repeatTrack() {
        audioPlayerService.toggleRepeat()
    }
    
    func playPrevTrack() {
        audioPlayerService.playPrevTrack()
    }
    
    func playPause() {
        audioPlayerService.togglePlayPause()
    }
    
    func playNextTrack() {
        audioPlayerService.playNextTrack()
    }
    
    func rewindTrack(_ request: PlayerModel.Rewind.Request) {
        let time = CMTime(seconds: Double(request.sliderValue), preferredTimescale: 1)
        audioPlayerService.rewind(to: time)
    }
    
    func loadPlayPauseState() {
        let isPlaying = audioPlayerService.isPlaying()
        
        presenter.presentPlayPauseState(PlayerModel.PlayPause.Response(playPauseState: isPlaying))
    }
    
    func loadRepeatState() {
        let isRepeatEnabled = audioPlayerService.getRepeatState()
        
        presenter.presentRepeatState(PlayerModel.Repeat.Response(isRepeatEnabled: isRepeatEnabled))
    }
    
    func loadAudioOptions() {
        guard
            let currentTrack = audioPlayerService.getCurrentTrack()
        else {
            return
        }
        
        let isRemote = currentTrack is RemoteAudioFile
        
        presenter.presentAudioOptions(PlayerModel.AudioOptions.Response(
            audioFile: currentTrack,
            onEdit: { [weak self] in
                guard let self else { return }
                
                self.loadEditAudioScreen(audioFile: currentTrack)
            },
            onAddToPlaylist: { [weak self] in
                guard let self else { return }
                
                self.loadPlaylistsList(audioFile: currentTrack)
            },
            onDelete: { [weak self] in
                guard let self else { return }
                
                self.deleteAudioFile(audioFile: currentTrack)
            },
            onDownload: isRemote ? { [weak self] in
                guard let self else { return }
                
                self.downloadAudioFile(audioFile: currentTrack)
            } : nil
        ))
    }
    
    // MARK: - Private methods
    private func loadEditAudioScreen(audioFile: AudioFile) {
        let editVC = EditAudioAssembly.build(audioFile: audioFile, coreDataManager: coreDataManager)
        
        presenter.routeTo(vc: editVC)
    }
    
    private func loadPlaylistsList(audioFile: AudioFile) {
        let playlists = worker.getAllPlaylists()
        
        presenter.presentPlaylistsList(PlayerModel.Playlists.Response(audioFile: audioFile, playlists: playlists, onSelect: { [weak self] audioFile, playlist in
            guard let self else { return }
            
            do {
                try self.worker.saveToPlaylist(audioFile, to: playlist)
            } catch {
                self.presenter.presentError(PlayerModel.Error.Response(error: CloudDataError.saveFailed(error)))
            }
        }))
    }
    
    private func deleteAudioFile(audioFile: AudioFile) {
        Task {
            do {
                if let remote = audioFile as? RemoteAudioFile {
                    try await cloudDataService.delete(remote)
                } else if let local = audioFile as? DownloadedAudioFile {
                    try worker.deleteDownloadedAudioFile(local)
                }
                
                await MainActor.run {
                    audioPlayerService.removeTrackFromPlaylist(audioFile)
                }
                
            } catch {
                await MainActor.run {
                    presenter.presentError(PlayerModel.Error.Response(error: error))
                }
            }
        }
    }
    
    private func downloadAudioFile(audioFile: AudioFile) {
        Task {
            do {
                guard let remote = audioFile as? RemoteAudioFile else {
                    return
                }
                
                _ = try await cloudDataService.download(remote)
            } catch {
                await MainActor.run {
                    presenter.presentError(PlayerModel.Error.Response(error: error))
                }
            }
        }
    }
}
