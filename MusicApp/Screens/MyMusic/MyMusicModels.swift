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
            let buttonsState: Bool
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
            let index: Int
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
    
    enum UpdateAudio {
        struct Request {
            let selectedSegmentIndex: Int
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
    
    enum Delete {
        struct Request {
            let selectedSegmentIndex: Int
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
    
    enum Edit {
        struct Request {
        }
        
        struct Response {
            let isEditingMode: Bool
        }
        
        struct ViewModel {
            let isEditingMode: Bool
        }
    }
    
    enum PickTracks {
        struct Request {
        }
        
        struct Response {
            let state: Bool
        }
        
        struct ViewModel {
            let buttonTitle: String
        }
    }
    
    enum PreLoading {
        struct Request {
        }
        
        struct Response {
        }
        
        struct ViewModel {
            let buttonsState: Bool
        }
    }
    
    enum SortOptions {
        struct Request {
        }
        
        struct Response {
        }
        
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
    
    enum CellData {
        struct Request {
            let index: Int
        }
        
        struct Response {
            let index: Int
            let isEditingMode: Bool
            let isSelected: Bool
            let audioFile: AudioFile
        }
        
        struct ViewModel {
            let index: Int
            let isEditingMode: Bool
            let isSelected: Bool
            let name: String
            let artistName: String
            let durationInSeconds: Double?
        }
    }
    
    enum TrackSelection {
        struct Request {
            let index: Int
        }
        
        struct Response {
            let index: Int
        }
        
        struct ViewModel {
            let index: Int
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
