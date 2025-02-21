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
        let interactor = PlayerInteractor(presenter: presenter)
        let view = PlayerViewController(interactor: interactor)
        presenter.view = view
        
        return view
    }
}
