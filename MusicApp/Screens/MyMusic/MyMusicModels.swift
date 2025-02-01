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
    
    enum Sort {
        struct Request {
            let sortType: SortType
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
    
    enum Search {
        struct Request {
            let query: String
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
    
    enum Play {
        struct Request {
        }
        
        struct Response {
        }
        
        struct ViewModel {
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
