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
        let cloudAudioService = CloudAudioService()
        let interactor = MyMusicInteractor(presenter: presenter, cloudAuthService: cloudAuthService, cloudAudioService: cloudAudioService)
        let viewFactory = MyMusicViewFactory()
        let view = MyMusicViewController(interactor: interactor, viewFactory: viewFactory)
        presenter.view = view
        
        return view
    }
}
