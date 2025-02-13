//
//  StartScreenInteractor.swift
//  MusicApp
//
//  Created by Никита Агафонов on 24.12.2024.
//

import Foundation

final class StartScreenInteractor: StartScreenBusinessLogic {
    // MARK: - Variables
    private let presenter: StartScreenPresentationLogic
    private let worker: StartScreenWorkerLogic
    private let cloudAuthService: CloudAuthService
    
    // MARK: - Lifecycle
    init (presenter: StartScreenPresentationLogic, worker: StartScreenWorkerLogic, cloudAuthService: CloudAuthService) {
        self.presenter = presenter
        self.worker = worker
        self.cloudAuthService = cloudAuthService
    }
    
    // MARK: - Navigation determination
    func determineNavigationDestination() {
        Task {
            // Checking authorization for all cloud services.
            await checkAuthorizationForAllServices()
            
            // Perform an asynchronous delay so as not to block the main thread and allow the UI to load.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let self = self else { return }
                
                let isFirstLaunch = worker.isFirstLaunch()
                
                if isFirstLaunch {
                    print("Launching slider guide...")
                    worker.markOnboardingCompleted()
                    
                    // Routing to slider guide screen.
                    presenter.routeToSliderGuideScreen()
                } else {
                    print("Launching main screen...")
                    
                    // Routing to main import screen.
                    presenter.routeToMainImportScreen() // Main screen
                }
            }
        }
    }
    
    // MARK: - Authorization checking
    private func checkAuthorizationForAllServices() async {
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
}
