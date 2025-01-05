//
//  ImportScreenInteractor.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

final class ImportScreenInteractor: ImportScreenBusinessLogic, ImportScreenDataStore {
    private let presenter: ImportScreenPresentationLogic
    private let worker: ImportScreenWorkerLogic
    
    var sections = [
        ("Облачные хранилища", [
            ("Google drive", "ic-google-drive"),
            ("Yandex cloud", "ic-yandex-cloud"),
            ("Dropbox", "ic-dropbox"),
            ("One Drive", "ic-one-drive")
        ]),
        ("Другие источники", [
            ("Локальные файлы", "ic-local-files")
        ])
    ]
    
    var audioFiles: [ImportScreenModel.AudioFile] = [] {
        didSet {
            presenter.presentAudioFiles(files: audioFiles)
        }
    }
    
    init (presenter: ImportScreenPresentationLogic, worker: ImportScreenWorkerLogic) {
        self.presenter = presenter
        self.worker = worker
    }
    
    func handleCloudServiceSelection(service: ImportScreenModel.CloudServiceType) {
        worker.authorizeAndFetchFiles(for: service) { result in
            switch result {
            case .success(let files):
                self.audioFiles = files
            case .failure(let error):
                self.presenter.presentError(error: error)
            }
        }
    }
    
    func handleLocalFilesSelection() {
        worker.fetchLocalFiles { result in
            switch result {
            case .success(let files):
                self.audioFiles = files
            case .failure(let error):
                self.presenter.presentError(error: error)
            }
        }
    }
}
