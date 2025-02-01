//
//  AudioFilesOverviewScreenPresenter.swift
//  MusicApp
//
//  Created by Никита Агафонов on 07.01.2025.
//

import UIKit

final class AudioFilesOverviewScreenPresenter: AudioFilesOverviewScreenPresentationLogic {
    weak var view: AudioFilesOverviewScreenViewController?
    
    func presentStart(
        _ response: AudioFilesOverviewScreenModel.Start.Response
    ) {
        DispatchQueue.main.async {
            let serviceName = response.service.displayName
            self.view?
                .displayStart(
                    AudioFilesOverviewScreenModel.Start
                        .ViewModel(serviceName: serviceName)
                )
        }
    }
    
    func presentError(
        _ response: AudioFilesOverviewScreenModel.Error.Response
    ) {
        DispatchQueue.main.async {
            self.view?.displayError(AudioFilesOverviewScreenModel.Error.ViewModel(errorDescription: response.error.localizedDescription))
        }
    }
    
    func presentAudioFiles(
        _ response: AudioFilesOverviewScreenModel.FetchedFiles.Response
    ) {
        DispatchQueue.main.async {
            let audioFilesCount = response.audioFiles?.count ?? 0
            self.view?.displayAudioFiles(
                AudioFilesOverviewScreenModel.FetchedFiles
                    .ViewModel(audioFilesCount: audioFilesCount)
            )
        }
    }
    
    func presentDownloadedAudioFiles(
        _ response: AudioFilesOverviewScreenModel.DownloadAudio.Response
    ) {
        DispatchQueue.main.async {
            self.view?
                .displayDownloadAudio(
                    AudioFilesOverviewScreenModel.DownloadAudio
                        .ViewModel(urlFile: response.urlFile)
                )
        }
    }
    
    func routeTo() {
        view?.navigationController?
            .pushViewController(UIViewController(), animated: true)
    }
}
