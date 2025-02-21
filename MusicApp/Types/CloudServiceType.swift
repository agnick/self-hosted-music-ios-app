//
//  CloudServiceType.swift
//  MusicApp
//
//  Created by Никита Агафонов on 08.01.2025.
//

// Enumeration for representing cloud service types.
enum CloudServiceType: CaseIterable {
    case googleDrive
    case dropbox
        
    var displayName: String {
        switch self {
        case .googleDrive: return "Google Drive"
        case .dropbox: return "Dropbox"
        }
    }
}
