//
//  AddToPlaylistPresenter.swift
//  MusicApp
//
//  Created by Никита Агафонов on 06.03.2025.
//

import UIKit

final class AddToPlaylistPresenter: AddToPlaylistPresentationLogic {
    weak var view: AddToPlaylistViewController?
    
    func presentLocalAudioFiles(_ request: AddToPlaylistModel.LocalAudioFiles.Response) {
        DispatchQueue.main.async {
            self.view?.displayLocalAudioFiles(AddToPlaylistModel.LocalAudioFiles.ViewModel(filesCount: String(request.audioFiles.count), selectedFilesCount: String(request.selectedAudioFiles.count)))
        }
    }
    
    func presentPreLoading() {
        DispatchQueue.main.async {
            self.view?.displayPreLoading(AddToPlaylistModel.PreLoading.ViewModel(buttonsState: false))
        }
    }
    
    func presentCellData(_ response: AddToPlaylistModel.CellData.Response) {
        DispatchQueue.main.async {
            let viewModel = MyMusicModel.CellData.ViewModel(index: response.index, isEditingMode: response.isEditingMode, isSelected: response.isSelected, name: response.audioFile.name, artistName: response.audioFile.artistName, durationInSeconds: response.audioFile.durationInSeconds)
            
            self.view?.displayCellData(viewModel)
        }
    }
    
    func presentTrackSelection(_ response: AddToPlaylistModel.TrackSelection.Response) {
        DispatchQueue.main.async {
            self.view?.displayTrackSelection(AddToPlaylistModel.TrackSelection.ViewModel(index: response.index, isSelected: response.selectedAudioFiles.count > 0, selectedAudioFilesCount: String(response.selectedAudioFiles.count)))
        }
    }
    
    func presentPickAll(_ response: AddToPlaylistModel.PickTracks.Response) {
        DispatchQueue.main.async {
            let buttonTitle = response.state ? "Выбрать все" : "Отменить"
            
            self.view?.displayPickAll(AddToPlaylistModel.PickTracks.ViewModel(buttonTitle: buttonTitle, state: response.state, selectedAudioFilesCount: String(response.selectedAudioFiles.count)))
        }
    }
    
    func presentSendSelectedTracks(_ response: AddToPlaylistModel.SendTracks.Response) {
        DispatchQueue.main.async {
            self.view?.delegate?.didSelectAudioFiles(response.selectedAudioFiles)
        }
    }
    
    func presentError(_ response: AddToPlaylistModel.Error.Response) {
        DispatchQueue.main.async {
            self.view?
                .displayError(
                    AddToPlaylistModel.Error
                        .ViewModel(
                            errorDescription: response.error.localizedDescription
                        )
                )
        }
    }
    
    func routeTo() {
        view?.navigationController?.pushViewController(UIViewController(), animated: true)
    }
}
