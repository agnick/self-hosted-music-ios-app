//
//  SettingsScreenPresenter.swift
//  MusicApp
//
//  Created by Никита Агафонов on 12.01.2025.
//

import UIKit

final class SettingsScreenPresenter: SettingsScreenPresentationLogic {
    weak var view: SettingsScreenViewController?
    
    func presentStart(_ request: SettingsScreenModel.Start.Response) {
        let cloudServiceName = request.cloudService?.displayName ?? "No service"
        
        view?.displayStart(SettingsScreenModel.Start.ViewModel(cloudServiceName: cloudServiceName))
    }
    
    func routeTo() {
        view?.navigationController?.pushViewController(UIViewController(), animated: true)
    }
}
