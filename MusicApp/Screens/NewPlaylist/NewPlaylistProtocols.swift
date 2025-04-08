//
//  NewPlaylistProtocols.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.03.2025.
//

import UIKit

protocol NewPlaylistBusinessLogic {
    func getCellData(_ request: NewPlaylistModel.CellData.Request)
    func loadSelectedTracks(_ request: NewPlaylistModel.SelectedTracks.Request)
    func removeTrack(_ request: NewPlaylistModel.RemoveTrack.Request)
    func loadPickedPlaylistImage(_ request: NewPlaylistModel.PlaylistImage.Request)
    func loadPlaylistName(_ request: NewPlaylistModel.PlaylistName.Request)
    
    func savePlaylist()
    func loadTrackPicker()
    func loadImagePicker()
}

protocol NewPlaylistDataStore {
    var selectedTracks: [AudioFile] { get set }
}

protocol NewPlaylistPresentationLogic {
    func presentCellData(_ response: NewPlaylistModel.CellData.Response)
    func presentPickedPlaylistImage(_ response: NewPlaylistModel.PlaylistImage.Response)
    func presentError(_ response: NewPlaylistModel.Error.Response)
    
    func presentSelectedTracks()
    func presentImagePicker()
    func getAddToPlaylistDelegate() -> AddToPlaylistDelegate?
    
    
    func routeTo(vc: UIViewController)
}

protocol NewPlaylistWorkerProtocol {
    func savePlaylistToCoreData(playlist: Playlist)
}
