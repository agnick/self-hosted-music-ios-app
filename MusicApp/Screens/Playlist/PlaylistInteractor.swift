import Foundation

final class PlaylistInteractor: PlaylistBusinessLogic, PlaylistDataStore {
    // MARK: - Variables
    private let presenter: PlaylistPresentationLogic
    private let worker: PlaylistWorkerProtocol
    private let coreDataManager: CoreDataManager
    private let cloudDataService: CloudDataService
    private let audioPlayerService: AudioPlayerService
    private let userDefaultsManager: UserDefaultsManager
    private let cloudAuthService: CloudAuthService
    
    var playlist: Playlist
    var audioFiles: [AudioFile] = []
    
    // MARK: - Lifecycle
    init (playlist: Playlist, presenter: PlaylistPresentationLogic, worker: PlaylistWorkerProtocol, coreDataManager: CoreDataManager, cloudDataService: CloudDataService, audioPlayerService: AudioPlayerService, userDefaultsManager: UserDefaultsManager, cloudAuthService: CloudAuthService) {
        self.playlist = playlist
        self.presenter = presenter
        self.worker = worker
        self.coreDataManager = coreDataManager
        self.cloudDataService = cloudDataService
        self.audioPlayerService = audioPlayerService
        self.userDefaultsManager = userDefaultsManager
        self.cloudAuthService = cloudAuthService
    }
    
    // MARK: - Public methods
    func loadPlaylistInfo() {
        do {
            playlist = try worker.fetchPlaylist(by: playlist.id)
            
            presenter.presentPlaylistInfo(PlaylistModel.PlaylistInfo.Response(playlistImage: playlist.image, playlistName: playlist.title))
        } catch {
            presenter.presentError(PlaylistModel.Error.Response(error: error))
        }
    }
    
    func loadAudioFiles() {
        do {
            playlist = try worker.fetchPlaylist(by: playlist.id)
            audioFiles = playlist.downloadedAudios + playlist.remoteAudios
            applySorting()
            presenter.presentAudioFiles()
        } catch {
            presenter.presentError(PlaylistModel.Error.Response(error: error))
        }
    }
    
    func loadAudioOptions(_ request: PlaylistModel.AudioOptions.Request) {
        let audioFile = request.audioFile
        let isRemote = audioFile is RemoteAudioFile
        
        presenter.presentAudioOptions(PlaylistModel.AudioOptions.Response(
            audioFile: audioFile,
            onEdit: { [weak self] in
                guard let self else { return }
                
                self.loadEditAudioScreen(audioFile: audioFile)
            },
            onAddToPlaylist: { [weak self] in
                guard let self else { return }
                
                self.loadPlaylistsList(audioFile: audioFile)
            },
            onDelete: { [weak self] in
                guard let self else { return }
                
                self.deleteAudioFile(audioFile: audioFile)
            },
            onDeleteFromPlaylist: { [weak self] in
                guard let self else { return }
                
                self.deleteAudioFileFromPlaylist(audioFile: audioFile)
            },
            onDownload: isRemote ? { [weak self] in
                guard let self else { return }
                
                self.downloadAudioFile(audioFile: audioFile)
            } : nil
        ))
    }
    
    func playInOrder() {
        guard
            let firstAudioFile = audioFiles.first
        else {
            return
        }
        
        audioPlayerService.play(audioFile: firstAudioFile, playlist: audioFiles)
    }
    
    func playShuffle() {
        guard !audioFiles.isEmpty else { return }
        
        var shuffledPlaylist = audioFiles
        shuffledPlaylist.shuffle()
        
        audioPlayerService.play(audioFile: shuffledPlaylist[0], playlist: shuffledPlaylist)
    }
    
    func playSelectedTrack(_ request: PlaylistModel.Play.Request) {
        let selectedTrack = audioFiles[request.index]
        audioPlayerService.play(audioFile: selectedTrack, playlist: audioFiles)
    }
    
    func loadEditor() {
        let editVC = NewPlaylistAssembly.buildEdit(playlist: playlist, coreDataManager: coreDataManager, userDefaultsManager: userDefaultsManager, cloudAuthService: cloudAuthService)
        presenter.routeTo(vc: editVC)
    }
    
    // MARK: - Private methods
    private func applySorting() {
        let sortType = worker.loadSortPreference()
        
        switch sortType {
        case .artistAscending:
            audioFiles.sort { $0.artistName < $1.artistName }
        case .artistDescending:
            audioFiles.sort { $0.artistName > $1.artistName }
        case .titleAscending:
            audioFiles.sort { $0.name < $1.name }
        case .titleDescending:
            audioFiles.sort { $0.name > $1.name }
        case .durationAscending:
            audioFiles.sort { $0.durationInSeconds < $1.durationInSeconds}
        case .durationDescending:
            audioFiles.sort { $0.durationInSeconds > $1.durationInSeconds}
        }
    }
    
    private func loadEditAudioScreen(audioFile: AudioFile) {
        let editVC = EditAudioAssembly.build(audioFile: audioFile, coreDataManager: coreDataManager)
        
        presenter.routeTo(vc: editVC)
    }
    
    private func loadPlaylistsList(audioFile: AudioFile) {
        let playlists = worker.getAllPlaylists(currentPlaylist: playlist)
        
        presenter.presentPlaylistsList(PlaylistModel.Playlists.Response(audioFile: audioFile, playlists: playlists, onSelect: { [weak self] audioFile, playlist in
            guard let self else { return }
            
            do {
                try self.worker.saveToPlaylist(audioFile, to: playlist)
            } catch {
                self.presenter.presentError(PlaylistModel.Error.Response(error: CloudDataError.saveFailed(error)))
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
                
                audioFiles.removeAll {
                    type(of: $0) == type(of: audioFile) && $0.id == audioFile.id
                }
                presenter.presentAudioFiles()
                
                await MainActor.run {
                    audioPlayerService.removeTrackFromPlaylist(audioFile)
                }
                
            } catch {
                await MainActor.run {
                    presenter.presentError(PlaylistModel.Error.Response(error: error))
                }
            }
        }
    }
    
    private func deleteAudioFileFromPlaylist(audioFile: AudioFile) {
        do {
            try worker.deleteFromPlaylist(audioFile, from: playlist)
            
            audioFiles.removeAll {
                type(of: $0) == type(of: audioFile) && $0.id == audioFile.id
            }
            presenter.presentAudioFiles()
        } catch {
            presenter.presentError(PlaylistModel.Error.Response(error: error))
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
                    presenter.presentError(PlaylistModel.Error.Response(error: error))
                }
            }
        }
    }
}
