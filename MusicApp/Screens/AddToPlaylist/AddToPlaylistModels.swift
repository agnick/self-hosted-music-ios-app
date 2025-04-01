import Foundation

enum AddToPlaylistModel {
    enum AudioFiles {
        struct Response {
            let audioFiles: [AudioFile]
            let selectedAudioFiles: Set<String>
        }
        
        struct ViewModel {
            let filesCount: String
            let selectedFilesCount: String
        }
    }
    
    enum PreLoading {
        struct ViewModel {
            let buttonsState: Bool
        }
    }
    
    enum TrackSelection {
        struct Request {
            let audioFile: AudioFile
            let indexPath: IndexPath
        }
        
        struct Response {
            let indexPath: IndexPath
            let selectedAudioFiles: Set<String>
        }
        
        struct ViewModel {
            let indexPath: IndexPath
            let isSelected: Bool
            let selectedAudioFilesCount: String
        }
    }
    
    enum PickTracks {
        struct Response {
            let state: Bool
            let selectedAudioFiles: Set<String>
        }
        
        struct ViewModel {
            let buttonTitle: String
            let state: Bool
            let selectedAudioFilesCount: String
        }
    }
    
    enum Search {
        struct Request {
            let query: String
        }
    }
    
    enum SendTracks {
        struct Response {
            let selectedAudioFiles: [AudioFile]
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
