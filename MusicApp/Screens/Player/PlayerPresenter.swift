//
//  PlayerPresenter.swift
//  MusicApp
//
//  Created by Никита Агафонов on 19.02.2025.
//

import UIKit

final class PlayerPresenter: PlayerPresentationLogic {
    weak var view: PlayerViewController?
    
    func presentStart(_ request: PlayerModel.Start.Response) {
        
    }
    
    func routeTo() {
        view?.navigationController?.pushViewController(UIViewController(), animated: true)
    }
}
