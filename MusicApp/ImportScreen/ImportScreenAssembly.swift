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
        let cloudAuthService = CloudAuthService()
        let interactor = ImportScreenInteractor(presenter: presenter, cloudAuthService: cloudAuthService)
        let view = ImportScreenViewController(interactor: interactor)
        presenter.view = view
        
        return view
    }
}
