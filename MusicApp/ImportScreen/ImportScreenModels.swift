//
//  ImportScreenModels.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

import Foundation

enum ImportScreenModel {
    enum AudioFilesFromCloud {
        struct Request {}
        
        struct Response {
            let cloudService: CloudServiceType
            let audioFiles: [AudioFile]
        }
        
        struct ViewModel {}
    }
}
