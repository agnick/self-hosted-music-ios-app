//
//  NewPlaylistAssembly.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.03.2025.
//

import UIKit

enum NewPlaylistAssembly {
    static func build(coreDataManager: CoreDataManager) -> UIViewController {
        let presenter = NewPlaylistPresenter()
        let worker = NewPlaylistWorker(coreDataManager: coreDataManager)
        let interactor = NewPlaylistInteractor(presenter: presenter, worker: worker)
        let view = NewPlaylistViewController(interactor: interactor)
        presenter.view = view
        
        return view
    }
}

