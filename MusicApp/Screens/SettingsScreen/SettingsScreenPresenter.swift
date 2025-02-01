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
        DispatchQueue.main.async {
            let cloudServiceName = request.cloudService?.displayName ?? "No service"
            
            self.view?.displayStart(SettingsScreenModel.Start.ViewModel(cloudServiceName: cloudServiceName))
        }
    }
    
    func routeTo() {
        view?.navigationController?.pushViewController(UIViewController(), animated: true)
    }
}
