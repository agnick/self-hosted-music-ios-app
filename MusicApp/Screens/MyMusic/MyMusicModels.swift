//
//  MyMusicModels.swift
//  MusicApp
//
//  Created by Никита Агафонов on 17.01.2025.
//

enum MyMusicModel {
    enum Start {
        struct Request {}
        
        struct Response {
            let cloudService: CloudServiceType?
        }
        
        struct ViewModel {
            let cloudServiceName: String
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
