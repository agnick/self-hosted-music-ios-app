//
//  PlaylistsProtocols.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.03.2025.
//

import UIKit

protocol PlaylistsBusinessLogic {
    func createPlaylist()
    func fetchAllPlaylists()
    func loadSortOptions()
    func sortPlaylists(_ request: PlaylistsModel.Sort.Request)
    func searchPlaylists(_ request: PlaylistsModel.Search.Request)
}

protocol PlaylistsDataStore {
    var playlists: [Playlist] { get set }
}

protocol PlaylistsPresentationLogic {
    func presentAllPlaylists()
    func presentSortOptions()
    
    func routeTo(vc: UIViewController)
}
