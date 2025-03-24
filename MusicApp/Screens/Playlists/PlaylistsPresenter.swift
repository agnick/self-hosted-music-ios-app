//
//  PlaylistsPresenter.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.03.2025.
//

import UIKit

final class PlaylistsPresenter: PlaylistsPresentationLogic {
    weak var view: PlaylistsViewController?
    
    func presentStart(_ request: PlaylistsModel.Start.Response) {
        
    }
    
    func routeTo(vc: UIViewController) {
        view?.navigationController?.pushViewController(vc, animated: true)
    }
}
