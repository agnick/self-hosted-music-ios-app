//
//  NewPlaylistPresenter.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.03.2025.
//

import UIKit

final class NewPlaylistPresenter: NewPlaylistPresentationLogic {
    weak var view: NewPlaylistViewController?
    
    func presentCellData(_ response: NewPlaylistModel.CellData.Response) {
        DispatchQueue.main.async {
            let viewModel = NewPlaylistModel.CellData.ViewModel(index: response.index, name: response.audioFile.name, artistName: response.audioFile.artistName, durationInSeconds: response.audioFile.durationInSeconds)
            
            self.view?.displayCellData(viewModel)
        }
    }
    
    func presentSelectedTracks() {
        DispatchQueue.main.async {
            self.view?.displaySelectedTracks()
        }
    }
    
    func presentImagePicker() {
        DispatchQueue.main.async {
            self.view?.displayImagePicker()
        }
    }
    
    func presentPickedPlaylistImage(_ response: NewPlaylistModel.PlaylistImage.Response) {
        DispatchQueue.main.async {
            self.view?.displayPickedImage(NewPlaylistModel.PlaylistImage.ViewModel(image: response.imageData))
        }
    }
    
    func presentError(_ response: NewPlaylistModel.Error.Response) {
        DispatchQueue.main.async {
            print("Error: \(response.error.localizedDescription)")
            self.view?.displayError(NewPlaylistModel.Error.ViewModel(errorDescription: response.error.localizedDescription))
        }
    }
    
    func routeTo(vc: UIViewController) {
        view?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getAddToPlaylistDelegate() -> AddToPlaylistDelegate? {
        return view
    }
}
