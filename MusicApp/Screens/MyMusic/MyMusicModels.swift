import UIKit

enum MyMusicModel {
    enum Start {
        struct Response {
            let cloudService: RemoteAudioSource?
        }
        
        struct ViewModel {
            let cloudServiceName: String
        }
    }
    
    enum FetchedFiles {
        struct Request {
            let source: RemoteAudioSource?
        }
        
        struct Response {
            let audioFiles: [AudioFile]?
        }
        
        struct ViewModel {
            let audioFilesCount: Int
            let buttonsState: Bool
        }
    }
    
    enum Sort {
        struct Request {
            let sortType: SortType
        }
    }
    
    enum Search {
        struct Request {
            let query: String
        }
    }
    
    enum Play {
        struct Request {
            let index: Int
        }
    }
    
    enum UpdateAudio {
        struct Request {
            let selectedSegmentIndex: Int
            let isRefresh: Bool
        }
    }
    
    enum HandleDelete {
        struct Request {
            let selectedSegmentIndex: Int
        }
    }
    
    enum DeleteAlert {
        struct Response {
            let service: RemoteAudioSource?
        }
        
        struct ViewModel {
            let alertTitle: String
            let alertMessage: String
            let service: RemoteAudioSource?
        }
    }
    
    enum Delete {
        struct Request {
            let service: RemoteAudioSource?
        }
    }
    
    enum Edit {
        struct Response {
            let isEditingMode: Bool
        }
        
        struct ViewModel {
            let isEditingMode: Bool
        }
    }
    
    enum PickTracks {
        struct Response {
            let state: Bool
        }
        
        struct ViewModel {
            let buttonTitle: String
            let state: Bool
        }
    }
    
    enum PreLoading {
        struct ViewModel {
            let buttonsState: Bool
        }
    }
    
    enum SortOptions {
        struct ViewModel {
            let sortOptions: [SortOption]
        }
        
        struct SortOption {
            let title: String
            let request: MyMusicModel.Sort.Request?
            let isCancel: Bool
            
            init(title: String, request: MyMusicModel.Sort.Request?, isCancel: Bool) {
                self.title = title
                self.request = request
                self.isCancel = isCancel
            }
        }
    }
    
    enum TrackSelection {
        struct Request {
            let index: Int
        }
        
        struct Response {
            let index: Int
            let selectedCount: Int
        }
        
        struct ViewModel {
            let index: Int
            let isSelected: Bool
        }
    }
    
    enum NotConnected {
        struct ViewModel {
            let message: String
        }
    }
    
    enum Download {
        struct Request {
            let audioFile: AudioFile
        }
    }
    
    enum DeleteTrack {
        struct Request {
            let audioFile: AudioFile
        }
    }
    
    enum AddToPlaylist {
        struct Request {
            let audioFile: AudioFile
            let playlist: PlaylistEntity
        }
    }
    
    enum AddSelectedToPlaylist {
        struct Request {
            let playlist: PlaylistEntity
        }
    }
    
    enum PlaylistsOptions {
        struct Request {
            let audioFile: AudioFile?
        }
        
        struct Response {
            let playlists: [PlaylistEntity]
            let audioFile: AudioFile?
            let isForSelectedTracks: Bool
        }
        
        struct ViewModel {
            let playlists: [PlaylistEntity]
            let audioFile: AudioFile?
            let isForSelectedTracks: Bool
        }
    }
    
    enum EditAudio {
        struct Request {
            let audioFile: AudioFile
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
