import UIKit

protocol PlayerBusinessLogic {
    func loadStart()
    func repeatTrack()
    func playPrevTrack()
    func playPause()
    func playNextTrack()
    func rewindTrack(_ request: PlayerModel.Rewind.Request)
    func loadPlayPauseState()
    func loadRepeatState()
    func loadAudioOptions()
}

protocol PlayerPresentationLogic {
    func presentStart(_ response: PlayerModel.Start.Response)
    func presentPlayPauseState(_ response: PlayerModel.PlayPause.Response)
    func presentRepeatState(_ response: PlayerModel.Repeat.Response)
    func presentAudioOptions(_ response: PlayerModel.AudioOptions.Response)
    func presentPlaylistsList(_ response: PlayerModel.Playlists.Response)
    func presentError(_ response: PlayerModel.Error.Response)
    
    func routeTo(vc: UIViewController)
}

protocol PlayerWorkerProtocol {
    func saveToPlaylist(_ audioFile: AudioFile, to playlist: PlaylistEntity) throws
    func getAllPlaylists() -> [PlaylistEntity]
    func deleteDownloadedAudioFile(_ audioFile: DownloadedAudioFile) throws
}
