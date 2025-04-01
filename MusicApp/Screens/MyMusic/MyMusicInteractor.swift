import Foundation

final class MyMusicInteractor: MyMusicBusinessLogic, MyMusicDataStore {
    // MARK: - Dependencies
    private let presenter: MyMusicPresentationLogic
    private let worker: MyMusicWorkerProtocol
    private let cloudAuthService: CloudAuthService
    private let cloudDataService: CloudDataService
    private let audioPlayerService: AudioPlayerService
    private let userDefaultsManager: UserDefaultsManager
    private let coreDataManager: CoreDataManager
    
    // MARK: - States
    private var searchQuery: String = ""
    private var isEditing = false
    private var originalAudioFiles: [AudioFile] = []
    private var currentFetchTask: Task<Void, Never>?
    var isEditingModeEnabled: Bool {
        return isEditing
    }
    var currentAudioFiles: [AudioFile] = []
    var selectedTracks: Set<String> = []
    var currentService: RemoteAudioSource?
    
    // MARK: - Lifecycle
    init (presenter: MyMusicPresentationLogic, worker: MyMusicWorkerProtocol, cloudAuthService: CloudAuthService, cloudDataService: CloudDataService, audioPlayerService: AudioPlayerService, userDefaultsManager: UserDefaultsManager, coreDataManager: CoreDataManager) {
        self.presenter = presenter
        self.worker = worker
        self.cloudAuthService = cloudAuthService
        self.cloudDataService = cloudDataService
        self.audioPlayerService = audioPlayerService
        self.userDefaultsManager = userDefaultsManager
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Public methods
    func loadStart() {
        currentService = cloudAuthService.currentService
        presenter.presentStart(MyMusicModel.Start.Response(cloudService: currentService))
    }
    
    func updateAudioFiles(_ request: MyMusicModel.UpdateAudio.Request) {
        currentFetchTask?.cancel()
        
        if request.selectedSegmentIndex == 0, cloudAuthService.currentService == nil {
            originalAudioFiles.removeAll()
            currentAudioFiles.removeAll()
            selectedTracks.removeAll()
            
            presenter.presentAudioFiles(MyMusicModel.FetchedFiles.Response(audioFiles: []))
            
            presenter.presentNotConnectedMessage()
            
            return
        }
        
        let segmentIndex = request.selectedSegmentIndex
        switch segmentIndex {
        case 0:
            if let service = cloudAuthService.currentService {
                currentAudioFiles = []
                presenter.presentPreLoading()
                currentFetchTask = Task {
                    await fetchCloudAudioFiles(service, forceRefresh: request.isRefresh)
                }
            }
        case 1:
            currentAudioFiles = []
            presenter.presentPreLoading()
            currentFetchTask = Task {
                await fetchLocalAudioFiles()
            }
        default:
            currentAudioFiles = []
        }
    }
    
    func sortAudioFiles(_ request: MyMusicModel.Sort.Request) {
        userDefaultsManager.saveSortPreference(request.sortType, for: UserDefaultsKeys.sortAudiosKey)
        applySortingAndFiltering()
    }
    
    func searchAudioFiles(_ request: MyMusicModel.Search.Request) {
        searchQuery = request.query
        applySortingAndFiltering()
    }
    
    func handleDeleteSelectedTracks(_ request: MyMusicModel.HandleDelete.Request) {
        let selectedSegment = request.selectedSegmentIndex
        
        switch selectedSegment {
        case 0:
            presenter.presentDeleteAlert(MyMusicModel.DeleteAlert.Response(service: cloudAuthService.currentService))
        case 1:
            presenter.presentDeleteAlert(MyMusicModel.DeleteAlert.Response(service: nil))
        default:
            break
        }
    }
    
    func deleteSelectedTracks(_ request: MyMusicModel.Delete.Request) {
        Task {
            do {
                for audioFile in currentAudioFiles where selectedTracks.contains(audioFile.id.uuidString) {
                    if let remote = audioFile as? RemoteAudioFile {
                        try await cloudDataService.delete(remote)
                    } else if let local = audioFile as? DownloadedAudioFile {
                        try worker.deleteDownloadedAudioFile(local)
                    }
                    
                    await MainActor.run {
                        audioPlayerService.removeTrackFromPlaylist(audioFile)
                    }
                }
                
                if let service = request.service {
                    await fetchCloudAudioFiles(service)
                } else {
                    await fetchLocalAudioFiles()
                }
            } catch {
                await MainActor.run {
                    presenter.presentError(MyMusicModel.Error.Response(error: error))
                }
            }
        }
    }
    
    func loadEdit() {
        isEditing.toggle()
        selectedTracks.removeAll()
        
        presenter.presentEdit(MyMusicModel.Edit.Response(isEditingMode: isEditing))
    }
    
    func pickAll() {
        let allSelected = selectedTracks.count == currentAudioFiles.count
        
        if allSelected {
            selectedTracks.removeAll()
        } else {
            selectedTracks = Set(currentAudioFiles.map {
                uniqueTrackID(for: $0)
            })
        }
        
        presenter.presentPickAll(MyMusicModel.PickTracks.Response(state: allSelected))
    }
    
    func playInOrder() {
        guard
            let firstAudioFile = currentAudioFiles.first
        else {
            return
        }
        
        audioPlayerService.play(audioFile: firstAudioFile, playlist: currentAudioFiles)
    }
    
    func playShuffle() {
        guard !currentAudioFiles.isEmpty else { return }
        
        var shuffledPlaylist = currentAudioFiles
        shuffledPlaylist.shuffle()
        
        audioPlayerService.play(audioFile: shuffledPlaylist[0], playlist: shuffledPlaylist)
    }
    
    func playNextTrack() {
        audioPlayerService.playNextTrack()
    }
    
    func playSelectedTrack(_ request: MyMusicModel.Play.Request) {
        if (!isEditing) {
            let selectedTrack = currentAudioFiles[request.index]
            audioPlayerService.play(audioFile: selectedTrack, playlist: currentAudioFiles)
        }
    }
    
    func loadSortOptions() {
        presenter.presentSortOptions()
    }
    
    func toggleTrackSelection(_ request: MyMusicModel.TrackSelection.Request) {
        let audioFile = currentAudioFiles[request.index]
        let trackID = uniqueTrackID(for: audioFile)
        let isSelected = selectedTracks.contains(trackID)
        
        if isSelected {
            selectedTracks.remove(trackID)
        } else {
            selectedTracks.insert(trackID)
        }
        
        presenter.presentTrackSelection(MyMusicModel.TrackSelection.Response(index: request.index, selectedCount: selectedTracks.count))
    }
    
    func downloadTrack(_ request: MyMusicModel.Download.Request) {
        Task {
            do {
                guard let remote = request.audioFile as? RemoteAudioFile else {
                    return
                }
                
                _ = try await cloudDataService.download(remote)
            } catch {
                await MainActor.run {
                    presenter.presentError(MyMusicModel.Error.Response(error: error))
                }
            }
        }
    }
    
    func deleteTrack(_ request: MyMusicModel.DeleteTrack.Request) {
        Task {
            do {
                let audioFile = request.audioFile
                
                if let remote = audioFile as? RemoteAudioFile {
                    try await cloudDataService.delete(remote)
                    await fetchCloudAudioFiles(remote.source)
                } else if let local = audioFile as? DownloadedAudioFile {
                    try worker.deleteDownloadedAudioFile(local)
                    await fetchLocalAudioFiles()
                }
                
                await MainActor.run {
                    audioPlayerService.removeTrackFromPlaylist(audioFile)
                }
            } catch {
                await MainActor.run {
                    presenter.presentError(MyMusicModel.Error.Response(error: error))
                }
            }
        }
    }
    
    func loadPlaylistOptions(_ request: MyMusicModel.PlaylistsOptions.Request) {
        let playlists = worker.getAllPlaylists()
        
        presenter.presentPlaylistOptions(MyMusicModel.PlaylistsOptions.Response(playlists: playlists, audioFile: request.audioFile, isForSelectedTracks: false))
    }
    
    func loadPlaylistOptionsForSelectedTracks() {
        let playlists = worker.getAllPlaylists()
        
        presenter.presentPlaylistOptions(MyMusicModel.PlaylistsOptions.Response(playlists: playlists, audioFile: nil, isForSelectedTracks: false))
    }
    
    func addToPlaylist(_ request: MyMusicModel.AddToPlaylist.Request) {
        do {
            try worker.saveToPlaylist(request.audioFile, to: request.playlist)
        } catch {
            presenter.presentError(MyMusicModel.Error.Response(error: error))
        }
    }
    
    func addSelectedTracksToPlaylist(_ request: MyMusicModel.AddSelectedToPlaylist.Request) {
        let selected = currentAudioFiles.filter { selectedTracks.contains($0.id.uuidString) }
        
        for file in selected {
            do {
                try worker.saveToPlaylist(file, to: request.playlist)
            } catch {
                presenter.presentError(MyMusicModel.Error.Response(error: error))
            }
        }
    }
    
    func loadEditAudioScreen(_ request: MyMusicModel.EditAudio.Request) {
        let editVC = EditAudioAssembly.build(audioFile: request.audioFile, coreDataManager: coreDataManager)
        
        presenter.routeTo(vc: editVC)
    }
    
    // MARK: - Private methods
    private func fetchCloudAudioFiles(_ source: RemoteAudioSource, forceRefresh: Bool = false) async {
        guard !Task.isCancelled else { return }
        
        if forceRefresh {
            do {
                let fresh = try await cloudDataService.fetchFiles()
                originalAudioFiles = fresh
                applySortingAndFiltering()
                
                await MainActor.run {
                    presenter.presentAudioFiles(MyMusicModel.FetchedFiles.Response(audioFiles: fresh))
                }
            } catch {
                await MainActor.run {
                    presenter.presentError(MyMusicModel.Error.Response(error: error))
                }
                return
            }
        }
        
        let cached = worker.fetchRemoteAudioFiles(from: source)
        originalAudioFiles = cached
        applySortingAndFiltering()
        
        await MainActor.run {
            presenter.presentAudioFiles(MyMusicModel.FetchedFiles.Response(audioFiles: cached))
        }
    }
    
    private func fetchLocalAudioFiles() async {
        guard !Task.isCancelled else { return }
        
        let cached = worker.fetchDownloadedAudioFiles()
        originalAudioFiles = cached
        applySortingAndFiltering()
        
        await MainActor.run {
            presenter.presentAudioFiles(MyMusicModel.FetchedFiles.Response(audioFiles: cached))
        }
    }
    
    private func applySortingAndFiltering() {
        guard
            !Task.isCancelled
        else {
            return
        }
        
        let sortType = userDefaultsManager.loadSortPreference(for: UserDefaultsKeys.sortAudiosKey)
        
        currentAudioFiles = originalAudioFiles
        
        if !searchQuery.isEmpty {
            currentAudioFiles = currentAudioFiles.filter {
                $0.name.lowercased().contains(searchQuery.lowercased()) ||
                $0.artistName.lowercased().contains(searchQuery.lowercased())
            }
        }

        switch sortType {
        case .artistAscending:
            currentAudioFiles.sort { $0.artistName < $1.artistName }
        case .artistDescending:
            currentAudioFiles.sort { $0.artistName > $1.artistName }
        case .titleAscending:
            currentAudioFiles.sort { $0.name < $1.name }
        case .titleDescending:
            currentAudioFiles.sort { $0.name > $1.name }
        case .durationAscending:
            currentAudioFiles.sort { $0.durationInSeconds < $1.durationInSeconds}
        case .durationDescending:
            currentAudioFiles.sort { $0.durationInSeconds > $1.durationInSeconds}
        }

        presenter.presentAudioFiles(MyMusicModel.FetchedFiles.Response(audioFiles: currentAudioFiles))
    }
    
    private func uniqueTrackID(for audioFile: AudioFile) -> String {
        return audioFile.id.uuidString
    }
}
