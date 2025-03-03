//
//  PlayerAssembly.swift
//  MusicApp
//
//  Created by Никита Агафонов on 19.02.2025.
//

import UIKit

enum PlayerAssembly {
    static func build() -> UIViewController {
        let presenter = PlayerPresenter()
        let audioPlayerService = AudioPlayerService()
        let interactor = PlayerInteractor(presenter: presenter, audioPlayerService: audioPlayerService)
        let viewFactory = PlayerViewFactory()
        let view = PlayerViewController(interactor: interactor, viewFactory: viewFactory)
        presenter.view = view
        
        return view
    }
}
