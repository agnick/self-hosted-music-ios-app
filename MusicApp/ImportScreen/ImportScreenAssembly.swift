//
//  ImportScreenAssembly.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

import UIKit

enum ImportScreenAssembly {
    static func build() -> UIViewController {
        let presenter = ImportScreenPresenter()
        let worker = ImportScreenWorker()
        let interactor = ImportScreenInteractor(presenter: presenter, worker: worker)
        let view = ImportScreenViewController(interactor: interactor)
        presenter.view = view
        
        return view
    }
}
