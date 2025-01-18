//
//  AudioImportAssembly.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

import UIKit

enum AudioImportAssembly {
    static func build() -> UIViewController {
        let presenter = AudioImportPresenter()
        let cloudAuthService = CloudAuthService()
        let interactor = AudioImportInteractor(presenter: presenter, cloudAuthService: cloudAuthService)
        let view = AudioImportViewController(interactor: interactor)
        presenter.view = view
        
        return view
    }
}
