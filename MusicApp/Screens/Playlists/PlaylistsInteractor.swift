//
//  PlaylistsInteractor.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.03.2025.
//

final class PlaylistsInteractor: PlaylistsBusinessLogic, PlaylistsDataStore {
    // MARK: - Variables
    private let presenter: PlaylistsPresentationLogic
    var playlists: [Playlist] = []
    
    // MARK: - Lifecycle
    init (presenter: PlaylistsPresentationLogic) {
        self.presenter = presenter
    }
    
    // MARK: - Public methods
    func loadStart(_ request: PlaylistsModel.Start.Request) {
        presenter.presentStart(PlaylistsModel.Start.Response())
    }
    
    func createPlaylist() {
        presenter.routeTo(vc: NewPlaylistAssembly.build())
    }
}
