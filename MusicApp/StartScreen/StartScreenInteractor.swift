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
    
    // MARK: - Lifecycle
    init (presenter: StartScreenPresentationLogic, worker: StartScreenWorkerLogic) {
        self.presenter = presenter
        self.worker = worker
    }
    
    // MARK: - Navigation determination
    func determineNavigationDestination(_ request: StartScreenModel.NavigationDestination.Request) {
        
        // Perform an asynchronous delay so as not to block the main thread and allow the UI to load.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
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
