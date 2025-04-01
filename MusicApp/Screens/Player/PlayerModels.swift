import UIKit
import CoreMedia

enum PlayerModel {
    enum Start {
        struct Response {
            let currentTrack: AudioFile
            let currentTime: Double
        }
        
        struct ViewModel {
            let trackName: String
            let artistName: String
            let trackImage: UIImage
            let trackDuration: Double?
            let currentTime: Double
        }
    }
    
    enum PlayPause {
        struct Response {
            let playPauseState: Bool
        }
        
        struct ViewModel {
            let playPauseImage: UIImage
        }
    }
    
    enum Repeat {
        struct Response {
            let isRepeatEnabled: Bool
        }
        
        struct ViewModel {
            let repeatImageColor: UIColor
        }
    }
    
    enum Rewind {
        struct Request {
            let sliderValue: Float
        }
    }
    
    enum AudioOptions {
        struct Request {
            let delegate: EditAudioViewControllerDelegate
        }
        
        struct Response {
            let audioFile: AudioFile
            let onEdit: () -> Void
            let onAddToPlaylist: () -> Void
            let onDelete: () -> Void
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
    
    enum Error {        
        struct Response {
            let error: Swift.Error
        }
        
        struct ViewModel {
            let errorDescription: String
        }
    }
}
