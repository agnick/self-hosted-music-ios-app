import UIKit

enum NewPlaylistModel {
    enum CellData {
        struct Request {
            let index: Int
        }
        
        struct Response {
            let index: Int
            let audioFile: AudioFile
        }
        
        struct ViewModel {
            let index: Int
            let name: String
            let artistName: String
            let image: UIImage
            let durationInSeconds: Double?
            let source: RemoteAudioSource?
        }
    }
    
    enum SelectedTracks {
        struct Request {
            let audioFiles: [AudioFile]
        }
    }
    
    enum PlaylistImage {
        struct Request {
            let imageData: Any?
        }
        
        struct Response {
            let imageData: UIImage
        }
        
        struct ViewModel {
            let image: UIImage
        }
    }
    
    enum RemoveTrack {
        struct Request {
            let index: Int
        }
    }
    
    enum PlaylistName {
        struct Request {
            let playlistName: String
        }
    }
    
    enum SavePlaylist {
        struct Request {
            let playlist: Playlist
        }
    }
    
    enum HardSetImage {
        struct Request {
            let image: UIImage?
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

enum NewPlaylistError: LocalizedError {
    case duplicateName
    case saveFailed(Error)

    var errorDescription: String? {
        switch self {
        case .duplicateName:
            return "Плейлист с таким названием уже существует"
        case .saveFailed(let error):
            return "Не удалось сохранить данные: \(error.localizedDescription)"
        }
    }
}

enum PlaylistEditingMode {
    case create
    case edit(Playlist)
}
