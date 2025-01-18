//
//  SettingsScreenModels.swift
//  MusicApp
//
//  Created by Никита Агафонов on 12.01.2025.
//

enum SettingsScreenModel {
    enum Start {
        struct Request {}
        
        struct Response {
            let cloudService: CloudServiceType?
        }
        
        struct ViewModel {
            let cloudServiceName: String
        }
    }
    
    enum Logout {
        struct Request {}
        
        struct Response {}
        
        struct ViewModel {}
    }
}
