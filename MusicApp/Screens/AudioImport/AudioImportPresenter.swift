//
//  AudioImportPresenter.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

import UIKit

final class AudioImportPresenter: AudioImportPresentationLogic {
    // MARK: - AudioImportViewController link
    weak var view: AudioImportViewController?
    
    // MARK: - Present methods
    func presentFilePicker() {
        DispatchQueue.main.async {
            self.view?.displayFilePicker()
        }
    }
    
    func presentError(_ response: AudioImportModel.Error.Response) {
        DispatchQueue.main.async {
            print("Error: \(response.error.localizedDescription)")
            self.view?.displayError(viewModel: AudioImportModel.Error.ViewModel(errorDescription: response.error.localizedDescription))
        }
    }
    
    // MARK: - Routing methods
    func routeToAudioFilesOverviewScreen(service: CloudServiceType) {
        DispatchQueue.main.async {
            self.view?.navigationController?.pushViewController(AudioFilesOverviewScreenAssembly.build(service: service), animated: true)
        }
    }
}
