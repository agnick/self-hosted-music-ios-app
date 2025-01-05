//
//  ImportScreenPresenter.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

import UIKit

final class ImportScreenPresenter: ImportScreenPresentationLogic {
    weak var view: ImportScreenViewController?
    
    func presentAudioFiles(files: [ImportScreenModel.AudioFile]) {
        let fileNames = files.map { $0.name }
        print("Fetched audio files: \(fileNames)")
    }
    
    func presentError(error: any Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    func routeTo() {
        view?.navigationController?.pushViewController(UIViewController(), animated: true)
    }
}
