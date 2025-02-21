//
//  AudioImportModels.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

import UIKit

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
            let vc: UIViewController
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
    
    enum LocalFiles {
        struct Request {
            let urls: [URL]
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
}
