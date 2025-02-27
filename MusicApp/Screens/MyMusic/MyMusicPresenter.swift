//
//  MyMusicPresenter.swift
//  MusicApp
//
//  Created by Никита Агафонов on 17.01.2025.
//

import UIKit

final class MyMusicPresenter: MyMusicPresentationLogic {
    weak var view: MyMusicViewController?
    
    func presentStart(_ response: MyMusicModel.Start.Response) {
        DispatchQueue.main.async {
            let cloudServiceName = response.cloudService?.displayName ?? "Не подключено"
            
            self.view?
                .displayStart(
                    MyMusicModel.Start.ViewModel(cloudServiceName: cloudServiceName)
                )
        }
    }
    
    func presentAudioFiles(
        _ response: MyMusicModel.FetchedFiles.Response
    ) {
        DispatchQueue.main.async {
            let audioFilesCount = response.audioFiles?.count ?? 0
            
            self.view?
                .displayAudioFiles(
                    MyMusicModel.FetchedFiles
                        .ViewModel(audioFilesCount: audioFilesCount, buttonsState: true)
                )
        }
    }
    
    func presentPreLoading() {
        DispatchQueue.main.async {
            self.view?.displayPreLoading(MyMusicModel.PreLoading.ViewModel(buttonsState: false))
        }
    }
    
    func presentEdit(_ response: MyMusicModel.Edit.Response) {
        DispatchQueue.main.async {
            self.view?.displayEdit(MyMusicModel.Edit.ViewModel(isEditingMode: response.isEditingMode))
        }
    }
    
    func presentPickAll(_ response: MyMusicModel.PickTracks.Response) {
        DispatchQueue.main.async {
            let buttonTitle = response.state ? "Выбрать все" : "Отменить"
            
            self.view?.displayPickAll(MyMusicModel.PickTracks.ViewModel(buttonTitle: buttonTitle, state: response.state))
        }
    }
    
    func presentSortOptions() {
        DispatchQueue.main.async {
            let options = [
                MyMusicModel.SortOptions.SortOption(title: "Исполнитель (А-я)", request: .init(sortType: .artistAscending), isCancel: false),
                MyMusicModel.SortOptions.SortOption(title: "Исполнитель (я-А)", request: .init(sortType: .artistDescending), isCancel: false),
                MyMusicModel.SortOptions.SortOption(title: "Название (А-я)", request: .init(sortType: .titleAscending), isCancel: false),
                MyMusicModel.SortOptions.SortOption(title: "Название (я-А)", request: .init(sortType: .titleDescending), isCancel: false),
                MyMusicModel.SortOptions.SortOption(title: "Длительность (дольше-короче)", request: .init(sortType: .durationDescending), isCancel: false),
                MyMusicModel.SortOptions.SortOption(title: "Длительность (короче-дольше)", request: .init(sortType: .durationAscending), isCancel: false),
                MyMusicModel.SortOptions.SortOption(title: "Отменить", request: nil, isCancel: true)
            ]
            
            self.view?.displaySortOptions(MyMusicModel.SortOptions.ViewModel(sortOptions: options))
        }
    }
    
    func presentCellData(_ response: MyMusicModel.CellData.Response) {
        DispatchQueue.main.async {
            let viewModel = MyMusicModel.CellData.ViewModel(index: response.index, isEditingMode: response.isEditingMode, isSelected: response.isSelected, name: response.audioFile.name, artistName: response.audioFile.artistName, durationInSeconds: response.audioFile.durationInSeconds)
            
            self.view?.displayCellData(viewModel)
        }
    }
    
    func presentTrackSelection(_ response: MyMusicModel.TrackSelection.Response) {
        DispatchQueue.main.async {
            self.view?.displayTrackSelection(MyMusicModel.TrackSelection.ViewModel(index: response.index, isSelected: response.selectedCount > 0))
        }
    }
    
    func presentNotConnectedMessage() {
        DispatchQueue.main.async {
            let message = "Авторизируйтесь в облачном сервисе для стриминга музыки"
            
            self.view?.displayNotConnectedMessage(MyMusicModel.NotConnected.ViewModel(message: message))
        }
    }
    
    func presentDeleteAlert(_ response: MyMusicModel.DeleteAlert.Response) {
        DispatchQueue.main.async {
            let alertMessage = "Это действие нельзя будет отменить"
            
            if let cloudService = response.service {
                self.view?.displayDeleteAlert(MyMusicModel.DeleteAlert.ViewModel(alertTitle: "Вы уверены что хотите удалить выбранные треки из вашего хранилища \(cloudService.displayName)?", alertMessage: alertMessage, service: cloudService))
            }
            
            self.view?.displayDeleteAlert(MyMusicModel.DeleteAlert.ViewModel(alertTitle: "Вы уверены что хотите удалить выбранные треки из файлов устройства?", alertMessage: alertMessage, service: nil))
        }
    }
    
    func presentError(_ response: MyMusicModel.Error.Response) {
        DispatchQueue.main.async {
            self.view?
                .displayError(
                    MyMusicModel.Error
                        .ViewModel(
                            errorDescription: response.error.localizedDescription
                        )
                )
        }
    }
    
    func routeTo() {
        view?.navigationController?
            .pushViewController(UIViewController(), animated: true)
    }
}
