import Foundation
import UIKit

protocol PlaylistBusinessLogic {
    func loadPlaylistInfo()
    func loadAudioFiles()
    func playInOrder()
    func playShuffle()
    func loadEditor()
    func loadAudioOptions(_ request: PlaylistModel.AudioOptions.Request)
    func playSelectedTrack(_ request: PlaylistModel.Play.Request)
}

protocol PlaylistPresentationLogic {
    func presentAudioFiles()
    func presentPlaylistInfo(_ response: PlaylistModel.PlaylistInfo.Response)
    func presentAudioOptions(_ response: PlaylistModel.AudioOptions.Response)
    func presentPlaylistsList(_ response: PlaylistModel.Playlists.Response)
    func presentError(_ response: PlaylistModel.Error.Response)
    
    func routeTo(vc: UIViewController)
}

protocol PlaylistDataStore {
    var audioFiles: [AudioFile] { get set }
}

protocol PlaylistWorkerProtocol {
    func loadSortPreference() -> SortType
    func getAllPlaylists(currentPlaylist: Playlist) -> [PlaylistEntity]
    func saveToPlaylist(_ audioFile: AudioFile, to playlist: PlaylistEntity) throws
    func deleteDownloadedAudioFile(_ audioFile: DownloadedAudioFile) throws
    func deleteFromPlaylist(_ audioFile: AudioFile, from playlist: Playlist) throws
    func fetchPlaylist(by id: UUID) throws -> Playlist
}
