//
//  MyMusicAssembly.swift
//  MusicApp
//
//  Created by Никита Агафонов on 17.01.2025.
//

import UIKit

enum MyMusicAssembly {
    static func build() -> UIViewController {
        let presenter = MyMusicPresenter()
        let cloudAuthService = CloudAuthService()
        let cloudAudioService = CloudAudioService(cloudAuthService: cloudAuthService)
        let localAudioService = LocalAudioService()
        let audioPlayerService = AudioPlayerService()
        let userDefaultsManager = UserDefaultsManager()
        let interactor = MyMusicInteractor(presenter: presenter, cloudAuthService: cloudAuthService, cloudAudioService: cloudAudioService, localAudioService: localAudioService, audioPlayerService: audioPlayerService, userDefaultsManager: userDefaultsManager)
        let viewFactory = MyMusicViewFactory()
        let view = MyMusicViewController(interactor: interactor, viewFactory: viewFactory)
        presenter.view = view
        
        return view
    }
}
