//
//  ImportScreenInteractor.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

import Foundation

final class AudioImportInteractor: AudioImportBusinessLogic {
    // MARK: - Variables
    private let presenter: AudioImportPresentationLogic
    private let cloudAuthService: CloudAuthService
    
    // MARK: - Lifecycle
    init (presenter: AudioImportPresentationLogic, cloudAuthService: CloudAuthService) {
        self.presenter = presenter
        self.cloudAuthService = cloudAuthService
    }
    
    // MARK: - Cloud Service Handling
    func handleCloudServiceSelection(_ request: AudioImportModel.CloudServiceSelection.Request) {
        if cloudAuthService.isAuthorized(for: request.service) {
            presenter.routeToAudioFilesOverviewScreen(service: request.service)
        } else {
            cloudAuthService.authorize(for: request.service) { [weak self] result in
                switch result {
                case .success:
                    self?.presenter.routeToAudioFilesOverviewScreen(service: request.service)
                case .failure(let error):
                    self?.presenter.presentError(AudioImportModel.Error.Response(error: error))
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
