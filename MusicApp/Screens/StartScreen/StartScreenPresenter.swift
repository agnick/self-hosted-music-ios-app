//
//  StartScreenPresenter.swift
//  MusicApp
//
//  Created by Никита Агафонов on 24.12.2024.
//

import UIKit

final class StartScreenPresenter: StartScreenPresentationLogic {
    // MARK: - Variables
    weak var view: StartScreenViewController?
    
    // MARK: - Routing methods
    func routeToMainImportScreen() {
        // Replaces the rootViewController to prevent returning to the start screen.
        // Ensures proper navigation flow on subsequent screens.
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        window.rootViewController = TabViewController()
        window.makeKeyAndVisible()
    }
    
    func routeToSliderGuideScreen() {
        view?.navigationController?
            .pushViewController(UIViewController(), animated: true)
    }
}
