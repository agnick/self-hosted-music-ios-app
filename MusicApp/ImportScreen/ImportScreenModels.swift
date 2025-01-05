//
//  ImportScreenModels.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

import Foundation

enum ImportScreenModel {
    // Замени на нужное
    enum Other {
        struct Request {}
        
        struct Response {}
        
        struct ViewModel {}
    }
    
    enum CloudServiceType {
        case googleDrive
        case yandexCloud
        case dropbox
        case oneDrive
    }
    
    struct AudioFile {
        let name: String
        let url: URL
    }
}
