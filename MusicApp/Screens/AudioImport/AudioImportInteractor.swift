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
            guard
                let currentService = cloudAuthService.getAuthorizedService()
            else {
                try await cloudAuthService.authorize(for: request.service, vc: request.vc)
                presenter
                    .routeToAudioFilesOverviewScreen(
                        service: request.service
                    )
                return
            }
            
            if currentService != request.service {
                presenter.presentAuthAlert(AudioImportModel.AuthAlert.Response(currentService: currentService, newService: request.service))
            } else {
                presenter
                    .routeToAudioFilesOverviewScreen(service: request.service)
            }
        }
    }
    
    func newAuthorize(_ request: AudioImportModel.NewAuth.Request) {
        Task {
            try await cloudAuthService.logout(from: request.currentService)
            try await cloudAuthService.authorize(for: request.newService, vc: request.vc)
            presenter
                .routeToAudioFilesOverviewScreen(
                    service: request.newService
                )
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
