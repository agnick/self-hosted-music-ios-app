//
//  DropboxFactory.swift
//  MusicApp
//
//  Created by Никита Агафонов on 21.02.2025.
//

final class DropboxFactory : CloudWorkerFactory {
    func createWorker() -> any CloudWorkerProtocol {
        return DropboxWorker()
    }
}
