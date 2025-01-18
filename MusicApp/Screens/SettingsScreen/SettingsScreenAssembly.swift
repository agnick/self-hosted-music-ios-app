//
//  SettingsScreenAssembly.swift
//  MusicApp
//
//  Created by Никита Агафонов on 12.01.2025.
//

import UIKit

enum SettingsScreenAssembly {
    static func build() -> UIViewController {
        let presenter = SettingsScreenPresenter()
        let cloudAuthService = CloudAuthService()
        let interactor = SettingsScreenInteractor(presenter: presenter, cloudAuthService: cloudAuthService)
        let view = SettingsScreenViewController(interactor: interactor)
        presenter.view = view
        
        return view
    }
}
