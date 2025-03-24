//
//  AddToPlaylistAssembly.swift
//  MusicApp
//
//  Created by Никита Агафонов on 06.03.2025.
//

import UIKit

enum AddToPlaylistAssembly {
    static func build() -> AddToPlaylistViewController {
        let presenter = AddToPlaylistPresenter()
        let localAudioService = LocalAudioService()
        let worker = AddToPlaylistWorker()
        let interactor = AddToPlaylistInteractor(presenter: presenter, localAudioService: localAudioService, worker: worker)
        let viewFactory = AddToPlaylistViewFactory()
        let view = AddToPlaylistViewController(interactor: interactor, viewFactory: viewFactory)
        presenter.view = view
        
        return view
    }
}
