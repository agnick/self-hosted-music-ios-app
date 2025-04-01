import UIKit

final class PlayerPresenter: PlayerPresentationLogic {
    // MARK: - Dependencies
    weak var view: PlayerViewController?
    
    // MARK: - Public methods
    func presentStart(_ request: PlayerModel.Start.Response) {
        DispatchQueue.main.async {
            self.view?.displayStart(PlayerModel.Start.ViewModel(trackName: request.currentTrack.name, artistName: request.currentTrack.artistName, trackImage: request.currentTrack.trackImg, trackDuration: request.currentTrack.durationInSeconds, currentTime: request.currentTime))
        }
    }
    
    func presentPlayPauseState(_ response: PlayerModel.PlayPause.Response) {
        DispatchQueue.main.async {
            let image: UIImage = response.playPauseState ? UIImage(image: .icPause) : UIImage(image: .icPlay)
            self.view?.displayPlayPauseState(PlayerModel.PlayPause.ViewModel(playPauseImage: image))
        }
    }
    
    func presentRepeatState(_ response: PlayerModel.Repeat.Response) {
        DispatchQueue.main.async {
            let imageColor: UIColor = response.isRepeatEnabled ? UIColor(color: .primary) : .black
            self.view?.displatRepeatState(PlayerModel.Repeat.ViewModel(repeatImageColor: imageColor))
        }
    }
    
    func presentAudioOptions(_ response: PlayerModel.AudioOptions.Response) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: response.audioFile.name, message: nil, preferredStyle: .actionSheet)

            let editAction = UIAlertAction(title: "Изменить", style: .default) { _ in
                response.onEdit()
            }
            let addToPlaylistAction = UIAlertAction(title: "Добавить в плейлист", style: .default) { _ in
                response.onAddToPlaylist()
            }
            let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                response.onDelete()
            }

            [editAction, addToPlaylistAction, deleteAction].forEach {
                $0.setValue(UIColor(color: .primary), forKey: "titleTextColor")
                alert.addAction($0)
            }

            if let onDownload = response.onDownload {
                let downloadAction = UIAlertAction(title: "Скачать", style: .default) { _ in
                    onDownload()
                }
                downloadAction.setValue(UIColor(color: .primary), forKey: "titleTextColor")
                alert.addAction(downloadAction)
            }

            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            cancelAction.setValue(UIColor(color: .primary), forKey: "titleTextColor")
            alert.addAction(cancelAction)

            self.view?.displayAudioOptions(PlayerModel.AudioOptions.ViewModel(alert: alert))
        }
    }

    
    func presentPlaylistsList(_ response: PlayerModel.Playlists.Response) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Добавить в плейлист",
                message: "Выберите плейлист",
                preferredStyle: .actionSheet
            )
            
            for playlist in response.playlists {
                let action = UIAlertAction(title: playlist.title, style: .default) { _ in
                    response.onSelect(response.audioFile, playlist)
                }
                
                action.setValue(UIColor(color: .primary), forKey: "titleTextColor")
                alert.addAction(action)
            }
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            cancelAction.setValue(UIColor(color: .primary), forKey: "titleTextColor")
            alert.addAction(cancelAction)
            
            self.view?.displayPlaylistsList(PlayerModel.Playlists.ViewModel(alert: alert))
        }
    }
    
    func presentError(_ response: PlayerModel.Error.Response) {
        DispatchQueue.main.async {
            self.view?
                .displayError(
                    PlayerModel.Error
                        .ViewModel(
                            errorDescription: response.error.localizedDescription
                        )
                )
        }
    }
    
    func routeTo(vc: UIViewController) {
        view?.navigationController?.pushViewController(vc, animated: true)
    }
}
