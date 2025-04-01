import UIKit

protocol MyMusicBusinessLogic {
    func loadStart()
    func sortAudioFiles(_ request: MyMusicModel.Sort.Request)
    func searchAudioFiles(_ request: MyMusicModel.Search.Request)
    func playSelectedTrack(_ request: MyMusicModel.Play.Request)
    func playInOrder()
    func playShuffle()
    func playNextTrack()
    func handleDeleteSelectedTracks(_ request: MyMusicModel.HandleDelete.Request)
    func deleteSelectedTracks(_ request: MyMusicModel.Delete.Request)
    func updateAudioFiles(_ request: MyMusicModel.UpdateAudio.Request)
    func loadEdit()
    func pickAll()
    func loadSortOptions()
    func toggleTrackSelection(_ request: MyMusicModel.TrackSelection.Request)
    func downloadTrack(_ request: MyMusicModel.Download.Request)
    func deleteTrack(_ request: MyMusicModel.DeleteTrack.Request)
    func addToPlaylist(_ request: MyMusicModel.AddToPlaylist.Request)
    func addSelectedTracksToPlaylist(_ request: MyMusicModel.AddSelectedToPlaylist.Request)
    func loadPlaylistOptions(_ request: MyMusicModel.PlaylistsOptions.Request)
    func loadPlaylistOptionsForSelectedTracks()
    func loadEditAudioScreen(_ request: MyMusicModel.EditAudio.Request)
}

protocol MyMusicDataStore {
    var currentAudioFiles: [AudioFile] { get set }
    var selectedTracks: Set<String> { get set }
    var isEditingModeEnabled: Bool { get }
    var currentService: RemoteAudioSource? { get set }
}

protocol MyMusicPresentationLogic {
    func presentStart(_ response: MyMusicModel.Start.Response)
    func presentAudioFiles(_ response: MyMusicModel.FetchedFiles.Response)
    func presentPreLoading()
    func presentEdit(_ response: MyMusicModel.Edit.Response)
    func presentPickAll(_ response: MyMusicModel.PickTracks.Response)
    func presentSortOptions()
    func presentTrackSelection(_ response: MyMusicModel.TrackSelection.Response)
    func presentNotConnectedMessage()
    func presentDeleteAlert(_ response: MyMusicModel.DeleteAlert.Response)
    func presentError(_ response: MyMusicModel.Error.Response)
    func presentPlaylistOptions(_ response: MyMusicModel.PlaylistsOptions.Response)
    
    func routeTo(vc: UIViewController)
}

protocol MyMusicWorkerProtocol {
    func saveToPlaylist(_ audioFile: AudioFile, to playlist: PlaylistEntity) throws
    func getAllPlaylists() -> [PlaylistEntity]
    func fetchRemoteAudioFiles(from source: RemoteAudioSource) -> [RemoteAudioFile]
    func fetchDownloadedAudioFiles() -> [DownloadedAudioFile]
    func deleteDownloadedAudioFile(_ audioFile: DownloadedAudioFile) throws
}
