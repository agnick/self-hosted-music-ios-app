//
//  StartScreenProtocols.swift
//  MusicApp
//
//  Created by Никита Агафонов on 24.12.2024.
//

protocol StartScreenBusinessLogic {
    func determineNavigationDestination()
}

protocol StartScreenWorkerLogic {
    func isFirstLaunch() -> Bool
    func markOnboardingCompleted()
}

protocol StartScreenPresentationLogic {
    func routeToMainImportScreen()
    func routeToSliderGuideScreen()
}
