//
//  PlaylistsProtocols.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.03.2025.
//

import UIKit

protocol PlaylistsBusinessLogic {
    func loadStart(_ request: PlaylistsModel.Start.Request)
    func createPlaylist()
}

protocol PlaylistsDataStore {
    var playlists: [Playlist] { get set }
}

protocol PlaylistsPresentationLogic {
    func presentStart(_ response: PlaylistsModel.Start.Response)
    
    func routeTo(vc: UIViewController)
}
