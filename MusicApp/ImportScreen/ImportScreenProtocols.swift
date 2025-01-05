//
//  ImportScreenProtocols.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

protocol ImportScreenBusinessLogic {
    func handleCloudServiceSelection(service: ImportScreenModel.CloudServiceType)
    func handleLocalFilesSelection()
}

protocol ImportScreenDataStore {
    var sections: [(String, [(String, String)])] { get }
    var audioFiles: [ImportScreenModel.AudioFile] { get set }
}

protocol ImportScreenWorkerLogic {
    func authorizeAndFetchFiles(for service: ImportScreenModel.CloudServiceType, completion: @escaping (Result<[ImportScreenModel.AudioFile], Error>) -> Void)
    func fetchLocalFiles(completion: @escaping (Result<[ImportScreenModel.AudioFile], Error>) -> Void)
}

protocol ImportScreenPresentationLogic {
    func presentAudioFiles(files: [ImportScreenModel.AudioFile])
    func presentError(error: Error)
    
    func routeTo()
}
