//
//  ImportScreenProtocols.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

protocol ImportScreenBusinessLogic {
    func handleCloudServiceSelection(service: CloudServiceType)
    func handleLocalFilesSelection()
    func checkAuthorizationForAllServices()
}

protocol ImportScreenPresentationLogic {
    func presentError(_ error: Error)
    
    func routeToAudioFilesOverviewScreen(service: CloudServiceType)
}
