//
//  CloudWorker.swift
//  MusicApp
//
//  Created by Никита Агафонов on 11.01.2025.
//

// MARK: - CloudWorkerService
struct CloudWorkerService {
    private let cloudWorker = CloudWorker.shared
    
    // MARK: - Public methods
    func getWorker(for service: CloudServiceType) -> CloudWorkerProtocol? {
        return cloudWorker.worker(for: service)
    }
}

// MARK: - CloudWorker
final class CloudWorker {
    static let shared: CloudWorker = CloudWorker()
    
    // MARK: - Variables
    private let workers: [CloudServiceType: CloudWorkerProtocol] = [
        .googleDrive: GoogleDriveWorker(),
        .yandexCloud: YandexCloudWorker(),
    ]
    
    // MARK: - Lifecycle
    private init() {}
    
    // MARK: - Utility methods
    func worker(for service: CloudServiceType) -> CloudWorkerProtocol? {
        return workers[service]
    }
}
