//
//  ImportScreenPresenter.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

import UIKit

final class ImportScreenPresenter: ImportScreenPresentationLogic {
    weak var view: ImportScreenViewController?
    
    // MARK: - Present methods
    func presentError(_ error: any Error) {
        print("Error: \(error.localizedDescription)")
        // Display error
    }
    
    // MARK: - Routing methods
    func routeToAudioFilesOverviewScreen(service: CloudServiceType) {
        view?.navigationController?.pushViewController(AudioFilesOverviewScreenAssembly.build(service: service), animated: true)
    }
}
