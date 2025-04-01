import UIKit
import CoreData

protocol PlaylistsBusinessLogic {
    func createPlaylist()
    func fetchAllPlaylists()
    func loadSortOptions()
    func sortPlaylists(_ request: PlaylistsModel.Sort.Request)
    func searchPlaylists(_ request: PlaylistsModel.Search.Request)
    func togglePlaylistsSelection(_ request: PlaylistsModel.TrackSelection.Request)
    func loadEdit()
    func deleteSelectedPlaylists()
    func loadPlaylistScreen(_ request: PlaylistsModel.LoadPlaylist.Request)
}

protocol PlaylistsDataStore {
    var playlists: [Playlist] { get set }
    var selectedPlaylistIDs: Set<UUID> { get set }
    var isEditingModeEnabled: Bool { get }
}

protocol PlaylistsPresentationLogic {
    func presentAllPlaylists()
    func presentSortOptions()
    func presentTrackSelection(_ response: PlaylistsModel.TrackSelection.Response)
    func presentEdit(_ response: PlaylistsModel.Edit.Response)
    func presentError(_ response: PlaylistsModel.Error.Response)
    
    func routeTo(vc: UIViewController)
}

protocol PlaylistsWorkerProtocol {
    func fetchAllPlaylists() throws -> [Playlist]
    func deletePlaylist(_ playlistId: UUID) throws
}
