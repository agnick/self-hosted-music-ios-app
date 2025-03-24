//
//  NewPlaylistAssembly.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.03.2025.
//

import UIKit

enum NewPlaylistAssembly {
    static func build() -> UIViewController {
        let presenter = NewPlaylistPresenter()
        let interactor = NewPlaylistInteractor(presenter: presenter)
        let view = NewPlaylistViewController(interactor: interactor)
        presenter.view = view
        
        return view
    }
}

