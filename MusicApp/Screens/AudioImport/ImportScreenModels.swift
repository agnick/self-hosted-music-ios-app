//
//  ImportScreenModels.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

import Foundation

enum AudioImportModel {
    enum Error {
        struct Request {}
        
        struct Response {
            let error: Swift.Error
        }
        
        struct ViewModel {
            let errorDescription: String
        }
    }
    
    enum CloudServiceSelection {
        struct Request {
            let service: CloudServiceType
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
}
