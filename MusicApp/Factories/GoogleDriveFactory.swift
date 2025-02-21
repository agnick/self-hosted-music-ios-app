//
//  GoogleDriveFactory.swift
//  MusicApp
//
//  Created by Никита Агафонов on 21.02.2025.
//

final class GoogleDriveFactory : CloudWorkerFactory {
    func createWorker() -> any CloudWorkerProtocol {
        return GoogleDriveWorker()
    }
}
