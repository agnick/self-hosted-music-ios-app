//
//  ImportScreenInteractor.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

import Foundation

final class ImportScreenInteractor: ImportScreenBusinessLogic {
    // MARK: - Variables
    private let presenter: ImportScreenPresentationLogic
    private let cloudAuthService: CloudAuthService
    
    // MARK: - Lifecycle
    init (presenter: ImportScreenPresentationLogic, cloudAuthService: CloudAuthService) {
        self.presenter = presenter
        self.cloudAuthService = cloudAuthService
    }
    
    // MARK: - Cloud Service Handling
    func handleCloudServiceSelection(service: CloudServiceType) {
        if cloudAuthService.isAuthorized(for: service) {
            presenter.routeToAudioFilesOverviewScreen(service: service)
        } else {
            cloudAuthService.authorize(for: service) { [weak self] result in
                switch result {
                case .success:
                    self?.presenter.routeToAudioFilesOverviewScreen(service: service)
                case .failure(let error):
                    self?.presenter.presentError(error)
                }
            }
        }
    }
    
    func checkAuthorizationForAllServices() {
        for service in CloudServiceType.allCases {
            if !cloudAuthService.isAuthorized(for: service) {
                reauthorizeService(service: service)
            }
        }
    }
    
    // MARK: - Local File Handling
    func handleLocalFilesSelection() {
        
    }
    
    // MARK: - Private methods
    private func reauthorizeService(service: CloudServiceType) {
        cloudAuthService.reauthorize(for: service) { result in
            switch result {
            case .success:
                print("\(service) reauthorized successfully.")
            case .failure(let error):
                print("Failed to reauthorize \(service): \(error.localizedDescription)")
            }
        }
    }
}
