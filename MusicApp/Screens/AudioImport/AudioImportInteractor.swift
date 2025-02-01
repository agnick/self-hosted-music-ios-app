//
//  AudioImportInteractor.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

import Foundation

final class AudioImportInteractor: AudioImportBusinessLogic {
    // MARK: - Variables
    private let presenter: AudioImportPresentationLogic
    private let cloudAuthService: CloudAuthService
    private let worker: AudioImportWorker
    
    // MARK: - Lifecycle
    init (
        presenter: AudioImportPresentationLogic,
        cloudAuthService: CloudAuthService,
        worker: AudioImportWorker
    ) {
        self.presenter = presenter
        self.cloudAuthService = cloudAuthService
        self.worker = worker
    }
    
    // MARK: - Cloud Service Handling
    func handleCloudServiceSelection(
        _ request: AudioImportModel.CloudServiceSelection.Request
    ) {
        Task {
            if cloudAuthService.isAuthorized(for: request.service) {
                presenter
                    .routeToAudioFilesOverviewScreen(service: request.service)
            } else {
                do {
                    try await cloudAuthService.authorize(for: request.service)
                    presenter
                        .routeToAudioFilesOverviewScreen(
                            service: request.service
                        )
                } catch {
                    presenter
                        .presentError(
                            AudioImportModel.Error.Response(error: error)
                        )
                }
            }
        }
    }
    
    func checkAuthorizationForAllServices() async {
        for service in CloudServiceType.allCases {
            do {
                try await cloudAuthService.reauthorize(for: service)
                print("\(service) reauthorized successfully.")
            } catch {
                print(
                    "Failed to reauthorize \(service): \(error.localizedDescription)"
                )
            }
        }
    }
    
    // MARK: - Local File Handling
    func handleLocalFilesSelection() {
        presenter.presentFilePicker()
    }
    
    func copySelectedFilesToAppSupportFolder(_ request: AudioImportModel.LocalFiles.Request) async {
        do {
            try await worker.copyFilesToAppFolder(files: request.urls)
        } catch {
            presenter.presentError(AudioImportModel.Error.Response(error: error))
        }
    }
    
    // MARK: - Private methods
    private func reauthorizeService(service: CloudServiceType) async {
        do {
            try await cloudAuthService.reauthorize(for: service)
            DispatchQueue.main.async {
                print("\(service) reauthorized successfully.")
            }
        } catch {
            DispatchQueue.main.async {
                print(
                    "Failed to reauthorize \(service): \(error.localizedDescription)"
                )
            }
        }
    }
}
