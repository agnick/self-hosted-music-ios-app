//
//  ImportScreenWorker.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

final class ImportScreenWorker: ImportScreenWorkerLogic {
    func authorizeAndFetchFiles(
        for service: ImportScreenModel.CloudServiceType,
        completion: @escaping (
            Result<[ImportScreenModel.AudioFile], Error>
        ) -> Void
    ) {
        switch service {
        case .googleDrive:
            completion(.success([]))
        case .yandexCloud:
            completion(.success([]))
        case .dropbox:
            completion(.success([]))
        case .oneDrive:
            completion(.success([]))
        }
    }
    
    func fetchLocalFiles(
        completion: @escaping (
            Result<[ImportScreenModel.AudioFile], any Error>
        ) -> Void
    ) {
        completion(.success([]))
    }
}
