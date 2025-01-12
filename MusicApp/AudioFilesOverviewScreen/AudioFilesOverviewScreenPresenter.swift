//
//  AudioFilesOverviewScreenPresenter.swift
//  MusicApp
//
//  Created by Никита Агафонов on 07.01.2025.
//

import UIKit

final class AudioFilesOverviewScreenPresenter: AudioFilesOverviewScreenPresentationLogic {
    weak var view: AudioFilesOverviewScreenViewController?
    
    func presentStart(_ response: AudioFilesOverviewScreenModel.Start.Response) {
        let serviceName = response.service.displayName
        view?.displayStart(AudioFilesOverviewScreenModel.Start.ViewModel(serviceName: serviceName))
    }
    
    func presentError(_ response: AudioFilesOverviewScreenModel.Error.Response) {
        view?.displayError(AudioFilesOverviewScreenModel.Error.ViewModel(errorDescription: response.error.localizedDescription))
    }
    
    func presentAudioFiles(_ response: AudioFilesOverviewScreenModel.FetchedFiles.Response) {
        let audioFilesCount = response.audioFiles?.count ?? 0
        view?.displayAudioFiles(AudioFilesOverviewScreenModel.FetchedFiles.ViewModel(audioFilesCount: audioFilesCount))
    }
    
    
    func routeTo() {
        view?.navigationController?.pushViewController(UIViewController(), animated: true)
    }
}
