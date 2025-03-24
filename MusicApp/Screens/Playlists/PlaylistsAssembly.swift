//
//  PlaylistsAssembly.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.03.2025.
//

import UIKit

enum PlaylistsAssembly {
    static func build() -> UIViewController {
        let presenter = PlaylistsPresenter()
        let interactor = PlaylistsInteractor(presenter: presenter)
        let view = PlaylistsViewController(interactor: interactor)
        presenter.view = view
        
        return view
    }
}
