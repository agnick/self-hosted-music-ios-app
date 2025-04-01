import Foundation

enum AudioFilesOverviewScreenModel {    
    enum Start {
        struct Response {
            let service: RemoteAudioSource
        }
        
        struct ViewModel {
            let serviceName: String
        }
    }
    
    enum FetchedFiles {
        struct Response {
            let audioFiles: [AudioFile]?
            let isUserInitiated: Bool
        }
        
        struct ViewModel {
            let audioFilesCount: Int
            let isUserInitiated: Bool
        }
    }
    
    enum DownloadAudio {
        struct Request {
            let audioFile: AudioFile
            let rowIndex: Int
        }
        
        struct Response {
            let fileName: String
            let isDownloaded: Bool
        }
        
        struct ViewModel {
            let fileName: String
            let isDownloaded: Bool
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
