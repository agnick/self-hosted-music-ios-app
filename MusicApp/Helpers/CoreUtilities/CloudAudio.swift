//
//  AudioManager.swift
//  MusicApp
//
//  Created by Никита Агафонов on 08.01.2025.
//

import Foundation

// MARK: - CloudAudioService
struct CloudAudioService {
    private let cloudAudio = CloudAudio.shared
    
    // MARK: - Public methods
    func fetchAudioFiles(
        for service: CloudServiceType,
        forceRefresh: Bool = false,
        completion: @escaping (Result<[AudioFile], Error>) -> Void
    ) {
        cloudAudio
            .fetchFiles(
                for: service,
                forceRefresh: forceRefresh,
                completion: completion
            )
    }
    
    func getAudioFiles() -> [AudioFile] {
        return cloudAudio.getAudioFiles()
    }
}

// MARK: - CloudAudio
final class CloudAudio {
    static let shared: CloudAudio = CloudAudio()
    
    // MARK: - Variables
    private var audioFiles: [AudioFile] = []
    private let cloudAuthService: CloudAuthService = CloudAuthService()
    private let cloudWorkerService: CloudWorkerService = CloudWorkerService()
        
    // MARK: - Lifecycle
    private init() {
    }
    
    // MARK: - File Fetching
    func fetchFiles(
        for service: CloudServiceType,
        forceRefresh: Bool = false,
        completion: @escaping (Result<[AudioFile], Error>) -> Void
    ) {
        guard let worker = cloudWorkerService.getWorker(for: service) else {
            completion(.failure(NSError(domain: "Worker not found", code: 404)))
            return
        }
        
        guard service == cloudAuthService.getAuthorizedService() else {
            completion(.failure(NSError(domain: "Not authorized", code: 401)))
            return
        }
        
        if forceRefresh {
            audioFiles.removeAll()
        }

        worker.fetchAudio { [weak self] result in
            switch result {
            case .success(let files):
                self?.audioFiles = files
                completion(.success(files))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Utility Methods
    func getAudioFiles() -> [AudioFile] {
        return audioFiles
    }
}
