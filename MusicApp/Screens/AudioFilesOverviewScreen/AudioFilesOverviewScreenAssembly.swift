//
//  AudioFilesOverviewScreenAssembly.swift
//  MusicApp
//
//  Created by Никита Агафонов on 07.01.2025.
//

import UIKit

enum AudioFilesOverviewScreenAssembly {
    static func build(service: CloudServiceType) -> UIViewController {
        let presenter = AudioFilesOverviewScreenPresenter()
        let cloudAudioService = CloudAudioService()
        let interactor = AudioFilesOverviewScreenInteractor(presenter: presenter, cloudAudioService: cloudAudioService, service: service)
        let view = AudioFilesOverviewScreenViewController(interactor: interactor)
        presenter.view = view
        
        return view
    }
}
