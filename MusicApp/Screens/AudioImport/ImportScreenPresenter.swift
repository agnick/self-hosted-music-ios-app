//
//  ImportScreenPresenter.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

import UIKit

final class AudioImportPresenter: AudioImportPresentationLogic {
    // MARK: - AudioImportViewController link
    weak var view: AudioImportViewController?
    
    // MARK: - Present methods
    func presentError(_ response: AudioImportModel.Error.Response) {
        print("Error: \(response.error.localizedDescription)")
        
        view?.displayError(viewModel: AudioImportModel.Error.ViewModel(errorDescription: response.error.localizedDescription))
    }
    
    // MARK: - Routing methods
    func routeToAudioFilesOverviewScreen(service: CloudServiceType) {
        view?.navigationController?.pushViewController(AudioFilesOverviewScreenAssembly.build(service: service), animated: true)
    }
}
