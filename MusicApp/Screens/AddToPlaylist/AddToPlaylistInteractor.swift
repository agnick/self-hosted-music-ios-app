import Foundation

final class AddToPlaylistInteractor: AddToPlaylistBusinessLogic, AddToPlaylistDataStore {
    // MARK: - Dependencies
    private let presenter: AddToPlaylistPresentationLogic
    private let worker: AddToPlaylistWorkerProtocol
    private let cloudAuthService: CloudAuthService
    
    // MARK: - States
    private var searchQuery: String = ""
    
    // MARK: - Stored collections
    var currentAudioFiles: [AudioFile] = []
    var selectedTracks: Set<String> = []
    private var originalAudioFiles: [AudioFile] = []
    private var remoteFiles: [RemoteAudioFile] = []
    private var localFiles: [DownloadedAudioFile] = []
    
    
    // MARK: - Lifecycle
    init (presenter: AddToPlaylistPresentationLogic, worker: AddToPlaylistWorkerProtocol, cloudAuthService: CloudAuthService) {
        self.presenter = presenter
        self.worker = worker
        self.cloudAuthService = cloudAuthService
    }
    
    // MARK: - Public methods
    func loadAudioFiles() {
        presenter.presentPreLoading()
        
        localFiles = worker.fetchDownloaded()
        
        if let service = cloudAuthService.currentService {
            remoteFiles = worker.fetchRemote(from: service)
        } else {
            remoteFiles.removeAll()
        }
        
        originalAudioFiles = remoteFiles as [AudioFile] + localFiles as [AudioFile]
        applySortingAndFiltering()
    }
    
    func toggleTrackSelection(_ request: AddToPlaylistModel.TrackSelection.Request) {
        let audioFile = request.audioFile
        let isSelected = selectedTracks.contains(audioFile.playbackUrl)
        
        if isSelected {
            selectedTracks.remove(audioFile.playbackUrl)
        } else {
            selectedTracks.insert(audioFile.playbackUrl)
        }
        
        presenter.presentTrackSelection(AddToPlaylistModel.TrackSelection.Response(indexPath: request.indexPath, selectedAudioFiles: selectedTracks))
    }
    
    func pickAll() {
        let allSelected = selectedTracks.count == currentAudioFiles.count
        
        if allSelected {
            selectedTracks.removeAll()
        } else {
            selectedTracks = Set(currentAudioFiles.map {
                $0.playbackUrl
            })
        }
        
        presenter.presentPickAll(AddToPlaylistModel.PickTracks.Response(state: allSelected, selectedAudioFiles: selectedTracks))
    }
    
    func searchAudioFiles(_ request: AddToPlaylistModel.Search.Request) {
        searchQuery = request.query
        applySortingAndFiltering()
    }
    
    func sendSelectedTracks() {
        let selectedAudioFiles = currentAudioFiles.filter {
            selectedTracks.contains($0.playbackUrl)
        }
        
        presenter.presentSendSelectedTracks(AddToPlaylistModel.SendTracks.Response(selectedAudioFiles: selectedAudioFiles))
    }
    
    // MARK: - Private methods
    private func applySortingAndFiltering() {
        let sortType = worker.loadSortPreference()
        
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

        presenter.presentAudioFiles(AddToPlaylistModel.AudioFiles.Response(audioFiles: currentAudioFiles, selectedAudioFiles: selectedTracks))
    }
    
    private func flatIndex(for indexPath: IndexPath) -> Int {
        switch indexPath.section {
        case 0:
            return indexPath.row
        case 1:
            let cloudCount = currentAudioFiles.filter { $0 is RemoteAudioFile }.count
            return cloudCount + indexPath.row
        default:
            return 0
        }
    }
}
