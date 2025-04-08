//
//  PlaylistsModels.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.03.2025.
//

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
}
