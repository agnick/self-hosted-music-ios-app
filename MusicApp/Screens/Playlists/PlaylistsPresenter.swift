//
//  PlaylistsPresenter.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.03.2025.
//

import UIKit

final class PlaylistsPresenter: PlaylistsPresentationLogic {
    weak var view: PlaylistsViewController?
    
    func presentAllPlaylists() {
        DispatchQueue.main.async {
            self.view?.displayAllPlaylists()
        }
    }
    
    func presentSortOptions() {
        DispatchQueue.main.async {
            let options = [
                PlaylistsModel.SortOptions.SortOption(title: "Название (А-я)", request: .init(sortType: .titleAscending), isCancel: false),
                PlaylistsModel.SortOptions.SortOption(title: "Название (я-А)", request: .init(sortType: .titleDescending), isCancel: false),
                PlaylistsModel.SortOptions.SortOption(title: "Отменить", request: nil, isCancel: true)
            ]
            
            self.view?.displaySortOptions(PlaylistsModel.SortOptions.ViewModel(sortOptions: options))
        }
    }
    
    func routeTo(vc: UIViewController) {
        view?.navigationController?.pushViewController(vc, animated: true)
    }
}
