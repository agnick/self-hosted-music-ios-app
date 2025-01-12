//
//  AudioFilesOverviewScreenModels.swift
//  MusicApp
//
//  Created by Никита Агафонов on 07.01.2025.
//

enum AudioFilesOverviewScreenModel {    
    enum Start {
        struct Request {}
        
        struct Response {
            let service: CloudServiceType
        }
        
        struct ViewModel {
            let serviceName: String
        }
    }
    
    enum FetchedFiles {
        struct Request {}
        
        struct Response {
            let audioFiles: [AudioFile]?
        }
        
        struct ViewModel {
            let audioFilesCount: Int
        }
    }
    
    enum Error {
        struct Request {}
        
        struct Response {
            let error: Swift.Error
        }
        
        struct ViewModel {
            let errorDescription: String
        }
    }
}
