//
//  StartScreenWorker.swift
//  MusicApp
//
//  Created by Никита Агафонов on 26.12.2024.
//

import Foundation

final class StartScreenWorker: StartScreenWorkerLogic {
    // MARK: - UserDefaults methods.
    // Returns current onboarding state.
    func isFirstLaunch() -> Bool {
        return !UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)
    }
    
    // Sets onboarding state to completed.
    func markOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
    }
}
