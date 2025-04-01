import UIKit
import CoreData

final class PlaylistsInteractor: PlaylistsBusinessLogic, PlaylistsDataStore {
    // MARK: - Dependencies
    private let presenter: PlaylistsPresentationLogic
    private let worker: PlaylistsWorkerProtocol
    private let coreDataManager: CoreDataManager
    private let userDefaultsManager: UserDefaultsManager
    private let cloudAuthService: CloudAuthService
    private let cloudDataService: CloudDataService
    private let audioPlayerService: AudioPlayerService
    
    // MARK: - States
    var playlists: [Playlist] = []
    var selectedPlaylistIDs: Set<UUID> = []
    var isEditingModeEnabled: Bool = false
    private var fetchedPlaylists: [Playlist] = []
    private var searchQuery: String = ""
    
    // MARK: - Lifecycle
    init (presenter: PlaylistsPresentationLogic, worker: PlaylistsWorkerProtocol, coreDataManager: CoreDataManager, userDefaultsManager: UserDefaultsManager, cloudAuthService: CloudAuthService, cloudDataService: CloudDataService, audioPlayerService: AudioPlayerService) {
        self.presenter = presenter
        self.worker = worker
        self.coreDataManager = coreDataManager
        self.userDefaultsManager = userDefaultsManager
        self.cloudAuthService = cloudAuthService
        self.cloudDataService = cloudDataService
        self.audioPlayerService = audioPlayerService
    }
    
    // MARK: - Public methods
    func createPlaylist() {
        presenter.routeTo(vc: NewPlaylistAssembly.buildCreate(coreDataManager: coreDataManager, userDefaultsManager: userDefaultsManager, cloudAuthService: cloudAuthService))
    }
    
    func fetchAllPlaylists() {
        do {
            fetchedPlaylists = try worker.fetchAllPlaylists()
            applySortingAndFiltering()
        } catch {
            presenter.presentError(PlaylistsModel.Error.Response(error: error))
        }
    }
    
    func loadSortOptions() {
        presenter.presentSortOptions()
    }
    
    func sortPlaylists(_ request: PlaylistsModel.Sort.Request) {
        userDefaultsManager.saveSortPreference(request.sortType, for: UserDefaultsKeys.sortPlaylistsKey)
        applySortingAndFiltering()
    }
    
    func searchPlaylists(_ request: PlaylistsModel.Search.Request) {
        searchQuery = request.query
        applySortingAndFiltering()
    }
    
    func togglePlaylistsSelection(_ request: PlaylistsModel.TrackSelection.Request) {
        let id = playlists[request.index].id
        
        if selectedPlaylistIDs.contains(id) {
            selectedPlaylistIDs.remove(id)
        } else {
            selectedPlaylistIDs.insert(id)
        }
        
        presenter.presentTrackSelection(PlaylistsModel.TrackSelection.Response(index: request.index, selectedCount: selectedPlaylistIDs.count))
    }
    
    func loadEdit() {
        isEditingModeEnabled.toggle()
        
        // Clear the set of selected tracks when entering or exiting editing mode.
        selectedPlaylistIDs.removeAll()
        
        presenter.presentEdit(PlaylistsModel.Edit.Response(isEditingMode: isEditingModeEnabled))
    }
    
    func deleteSelectedPlaylists() {
        do {
            for selectedPlaylistId in selectedPlaylistIDs {
                try worker.deletePlaylist(selectedPlaylistId)
            }
            
            fetchAllPlaylists()
            presenter.presentAllPlaylists()
        } catch {
            presenter.presentError(PlaylistsModel.Error.Response(error: error))
        }
    }
    
    func loadPlaylistScreen(_ request: PlaylistsModel.LoadPlaylist.Request) {
        let playlist = playlists[request.index]
        
        presenter.routeTo(vc: PlaylistAssembly.build(playlist: playlist, coreDataManager: coreDataManager, cloudDataService: cloudDataService, audioPlayerService: audioPlayerService, userDefaultsManager: userDefaultsManager, cloudAuthService: cloudAuthService))
    }
    
    // MARK: - Private methods
    private func applySortingAndFiltering() {
        let sortType = userDefaultsManager.loadSortPreference(for: UserDefaultsKeys.sortPlaylistsKey)
        
        playlists = fetchedPlaylists
        
        if !searchQuery.isEmpty {
            playlists = playlists.filter {
                $0.title.lowercased().contains(searchQuery.lowercased())
            }
        }

        switch sortType {
        case .titleAscending:
            playlists.sort { $0.title.lowercased() < $1.title.lowercased() }
        case .titleDescending:
            playlists.sort { $0.title.lowercased() > $1.title.lowercased() }
        default:
            break
        }

        presenter.presentAllPlaylists()
    }
}
