import UIKit

enum PlaylistModel {
    enum PlaylistInfo {
        struct Response {
            let playlistImage: UIImage
            let playlistName: String
        }
        
        struct ViewModel {
            let playlistImage: UIImage
            let playlistName: String
        }
    }
    
    enum AudioOptions {
        struct Request {
            let audioFile: AudioFile
        }
        
        struct Response {
            let audioFile: AudioFile
            let onEdit: () -> Void
            let onAddToPlaylist: () -> Void
            let onDelete: () -> Void
            let onDeleteFromPlaylist: () -> Void
            let onDownload: (() -> Void)?
        }
        
        struct ViewModel {
            let alert: UIAlertController
        }
    }
    
    enum Playlists {
        struct Response {
            let audioFile: AudioFile
            let playlists: [PlaylistEntity]
            let onSelect: (AudioFile, PlaylistEntity) -> Void
        }
        
        struct ViewModel {
            let alert: UIAlertController
        }
    }
    
    enum Play {
        struct Request {
            let index: Int
        }
    }
    
    enum Error {
        struct Response {
            let error: Swift.Error
        }
        
        struct ViewModel {
            let errorDescription: String
        }
    }
}

enum PlaylisError: LocalizedError {
    case invalidResponse
    case entityNotFound
    case saveFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Неожиданный ответ сервера."
        case .entityNotFound:
            return "Запись о файле не найдена в локальной базе."
        case .saveFailed(let error):
            return "Не удалось сохранить данные: \(error.localizedDescription)"
        }
    }
}
