//
//  MyMusicPresenter.swift
//  MusicApp
//
//  Created by Никита Агафонов on 17.01.2025.
//

import UIKit

final class MyMusicPresenter: MyMusicPresentationLogic {
    weak var view: MyMusicViewController?
    
    func presentStart(_ request: MyMusicModel.Start.Response) {
        let cloudServiceName = request.cloudService?.displayName ?? "Не подключено"
        view?.displayStart(MyMusicModel.Start.ViewModel(cloudServiceName: cloudServiceName))
    }
    
    func presentCloudAudioFiles(_ response: MyMusicModel.FetchedFiles.Response) {
        DispatchQueue.main.async {
            let audioFilesCount = response.audioFiles?.count ?? 0
            self.view?
                .displayAudioFiles(
                    MyMusicModel.FetchedFiles
                        .ViewModel(audioFilesCount: audioFilesCount)
                )
        }
    }
    
    func presentError(_ response: MyMusicModel.Error.Response) {
        DispatchQueue.main.async {
            self.view?
                .displayError(
                    MyMusicModel.Error
                        .ViewModel(
                            errorDescription: response.error.localizedDescription
                        )
                )
        }
    }
    
    func routeTo() {
        view?.navigationController?.pushViewController(UIViewController(), animated: true)
    }
}
