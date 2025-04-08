//
//  NewPlaylistInteractor.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.03.2025.
//

import Foundation
import UIKit

final class NewPlaylistInteractor: NewPlaylistBusinessLogic, NewPlaylistDataStore {
    // MARK: - Variables
    private let presenter: NewPlaylistPresentationLogic
    private let worker: NewPlaylistWorkerProtocol
    
    var selectedTracks: [AudioFile] = []
    private var playlistImage: UIImage?
    private var playlistName: String?
    
    // MARK: - Lifecycle
    init (presenter: NewPlaylistPresentationLogic, worker: NewPlaylistWorkerProtocol) {
        self.presenter = presenter
        self.worker = worker
    }
    
    // MARK: - Public methods
    func loadTrackPicker() {
        let addToPlaylistVC = AddToPlaylistAssembly.build()
        guard
            let delegate = presenter.getAddToPlaylistDelegate()
        else {
            return
        }
        
        addToPlaylistVC.delegate = delegate
        presenter.routeTo(vc: addToPlaylistVC)
    }
    
    func loadImagePicker() {
        presenter.presentImagePicker()
    }
    
    func loadPickedPlaylistImage(_ request: NewPlaylistModel.PlaylistImage.Request) {
        if let imageData = request.imageData as? UIImage {
            presenter.presentPickedPlaylistImage(NewPlaylistModel.PlaylistImage.Response(imageData: imageData))
            playlistImage = imageData
        } else {
            let error = NSError(
                domain: "NewPlaylistInteractor",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "Ошибка загрузки изображения"]
            )
            
            presenter.presentError(NewPlaylistModel.Error.Response(error: error))
            playlistImage = nil
        }
    }
    
    func loadPlaylistName(_ request: NewPlaylistModel.PlaylistName.Request) {
        playlistName = request.playlistName
    }
    
    func getCellData(_ request: NewPlaylistModel.CellData.Request) {
        guard request.index < selectedTracks.count else { return }
        
        let audioFile = selectedTracks[request.index]
        
        presenter.presentCellData(NewPlaylistModel.CellData.Response(index: request.index, audioFile: audioFile))
    }
    
    func loadSelectedTracks(_ request: NewPlaylistModel.SelectedTracks.Request) {
        for audioFile in request.audioFiles {
            if !selectedTracks.contains(audioFile) {
                selectedTracks.append(audioFile)
            }
        }
        
        presenter.presentSelectedTracks()
    }
    
    func removeTrack(_ request: NewPlaylistModel.RemoveTrack.Request) {
        guard
            request.index < selectedTracks.count
        else {
            return
        }
        
        selectedTracks.remove(at: request.index)
    }
    
    func savePlaylist() {
        let playlist = Playlist(image: playlistImage, title: playlistName, audios: selectedTracks)
        worker.savePlaylistToCoreData(playlist: playlist)
    }
}
