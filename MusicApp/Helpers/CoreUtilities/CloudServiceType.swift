//
//  CloudServiceType.swift
//  MusicApp
//
//  Created by Никита Агафонов on 08.01.2025.
//

// Enumeration for representing cloud service types.
enum CloudServiceType: CaseIterable {
    case googleDrive
    case yandexCloud
    case dropbox
    case oneDrive
        
    var displayName: String {
        switch self {
        case .googleDrive: return "Google Drive"
        case .yandexCloud: return "Yandex Cloud"
        case .dropbox: return "Dropbox"
        case .oneDrive: return "OneDrive"
        }
    }
}
