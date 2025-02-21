//
//  CloudWorkerFactory.swift
//  MusicApp
//
//  Created by Никита Агафонов on 21.02.2025.
//

protocol CloudWorkerFactory {
    func createWorker() -> CloudWorkerProtocol
}
