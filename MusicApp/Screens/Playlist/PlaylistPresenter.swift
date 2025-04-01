import UIKit

final class PlaylistPresenter: PlaylistPresentationLogic {
    // MARK: - Dependencies
    weak var view: PlaylistViewController?
    
    // MARK: - Public methods
    func presentPlaylistInfo(_ response: PlaylistModel.PlaylistInfo.Response) {
        DispatchQueue.main.async {
            self.view?.displayPlaylistInfo(PlaylistModel.PlaylistInfo.ViewModel(playlistImage: response.playlistImage, playlistName: response.playlistName))
        }
    }
    
    func presentAudioFiles() {
        DispatchQueue.main.async {
            self.view?.displayAudioFiles()
        }
    }
    
    func presentAudioOptions(_ response: PlaylistModel.AudioOptions.Response) {
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
            let deleteFromPlaylistAction = UIAlertAction(title: "Удалить из плейлиста", style: .destructive) { _ in
                response.onDeleteFromPlaylist()
            }

            [editAction, addToPlaylistAction, deleteAction, deleteFromPlaylistAction].forEach {
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

            self.view?.displayAudioOptions(PlaylistModel.AudioOptions.ViewModel(alert: alert))
        }
    }
    
    func presentPlaylistsList(_ response: PlaylistModel.Playlists.Response) {
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
            
            self.view?.displayPlaylistsList(PlaylistModel.Playlists.ViewModel(alert: alert))
        }
    }
    
    func presentError(_ response: PlaylistModel.Error.Response) {
        DispatchQueue.main.async {
            self.view?.displayError(PlaylistModel.Error.ViewModel(errorDescription: response.error.localizedDescription))
        }
    }
    
    func routeTo(vc: UIViewController) {
        view?.navigationController?.pushViewController(vc, animated: true)
    }
}
