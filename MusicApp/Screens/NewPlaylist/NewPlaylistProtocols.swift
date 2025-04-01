import UIKit

protocol NewPlaylistBusinessLogic {
    func getCellData(_ request: NewPlaylistModel.CellData.Request)
    func loadSelectedTracks(_ request: NewPlaylistModel.SelectedTracks.Request)
    func removeTrack(_ request: NewPlaylistModel.RemoveTrack.Request)
    func loadPickedPlaylistImage(_ request: NewPlaylistModel.PlaylistImage.Request)
    func loadPlaylistName(_ request: NewPlaylistModel.PlaylistName.Request)
    func loadHardSetImage(_ request: NewPlaylistModel.HardSetImage.Request)
    func savePlaylist()
    func loadTrackPicker()
    func loadImagePicker()
}

protocol NewPlaylistDataStore {
    var selectedTracks: [AudioFile] { get set }
}

protocol NewPlaylistPresentationLogic {
    func presentCellData(_ response: NewPlaylistModel.CellData.Response)
    func presentPickedPlaylistImage(_ response: NewPlaylistModel.PlaylistImage.Response)
    func presentError(_ response: NewPlaylistModel.Error.Response)
    func presentSelectedTracks()
    func presentImagePicker()
    func getAddToPlaylistDelegate() -> AddToPlaylistDelegate?
    func presentPlaylistSavedSuccessfully()
    
    func routeTo(vc: UIViewController)
}

protocol NewPlaylistWorkerProtocol {
    func savePlaylistToCoreData(mode: PlaylistEditingMode, playlist: Playlist) throws
}
