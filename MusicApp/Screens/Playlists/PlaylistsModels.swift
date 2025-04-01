import Foundation

enum PlaylistsModel {
    enum Sort {
        struct Request {
            let sortType: SortType
        }
    }
    
    enum SortOptions {
        struct ViewModel {
            let sortOptions: [SortOption]
        }
        
        struct SortOption {
            let title: String
            let request: PlaylistsModel.Sort.Request?
            let isCancel: Bool
            
            init(title: String, request: PlaylistsModel.Sort.Request?, isCancel: Bool) {
                self.title = title
                self.request = request
                self.isCancel = isCancel
            }
        }
    }
    
    enum Search {
        struct Request {
            let query: String
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
    
    enum LoadPlaylist {
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
