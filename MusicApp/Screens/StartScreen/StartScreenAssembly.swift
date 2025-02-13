//
//  StartScreenAssembly.swift
//  MusicApp
//
//  Created by Никита Агафонов on 24.12.2024.
//

import UIKit

enum StartScreenAssembly {
    static func build() -> UIViewController {
        let presenter = StartScreenPresenter()
        let worker = StartScreenWorker()
        let cloudAuthService = CloudAuthService()
        let interactor = StartScreenInteractor(presenter: presenter, worker: worker, cloudAuthService: cloudAuthService)
        let view = StartScreenViewController(interactor: interactor)
        presenter.view = view
        
        return view
    }
}
