//
//  StartScreenPresenter.swift
//  MusicApp
//
//  Created by Никита Агафонов on 24.12.2024.
//

import UIKit

final class StartScreenPresenter: StartScreenPresentationLogic {
    // MARK: - Variables
    weak var view: StartScreenViewController?
    
    // MARK: - Routing methods
    func routeToMainImportScreen() {
        view?.navigationController?.pushViewController(TabViewController(), animated: false)
    }
    
    func routeToSliderGuideScreen() {
        view?.navigationController?.pushViewController(UIViewController(), animated: false)
    }
}
