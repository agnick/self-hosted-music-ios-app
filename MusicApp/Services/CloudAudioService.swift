//
//  AudioManager.swift
//  MusicApp
//
//  Created by Никита Агафонов on 08.01.2025.
//

import Foundation

// MARK: - CloudAudio
final class CloudAudioService {
    // MARK: - Variables
    private var audioFiles: [AudioFile] = []
    private let cloudAuthService: CloudAuthService
    
    // MARK: - Lifecycle
    init(cloudAuthService: CloudAuthService) {
        self.cloudAuthService = cloudAuthService
    }
    
    // MARK: - File Fetching
    func fetchAudioFiles(
        for service: CloudServiceType,
        forceRefresh: Bool = false
    ) async throws -> [AudioFile] {
        guard let worker = cloudAuthService.getWorker(for: service) else {
            throw NSError(domain: "Worker not found", code: 404)
        }
        
        guard service == cloudAuthService.getAuthorizedService() else {
            throw NSError(domain: "Not authorized", code: 401)
        }
        
        if forceRefresh {
            audioFiles.removeAll()
        }

        let fetchedFiles = try await worker.fetchAudio()
        audioFiles = fetchedFiles
        return fetchedFiles
    }
    
    func downloadAudioFile(for service: CloudServiceType, from source: String, fileName: String) async throws -> Bool {
        guard let worker = cloudAuthService.getWorker(for: service) else {
            throw NSError(domain: "Worker not found", code: 404)
        }
        
        guard service == cloudAuthService.getAuthorizedService() else {
            throw NSError(domain: "Not authorized", code: 401)
        }
        
        guard
            let _ = try await worker.downloadAudioFile(from: source, fileName: fileName)
        else {
            return false
        }
        
        return true
    }
    
    func deleteAudioFile(for service: CloudServiceType, from source: String) async throws {
        guard let worker = cloudAuthService.getWorker(for: service) else {
            throw NSError(domain: "Worker not found", code: 404)
        }
        
        guard service == cloudAuthService.getAuthorizedService() else {
            throw NSError(domain: "Not authorized", code: 401)
        }
        
        try await worker.deleteAudioFile(from: source)
    }
        
    // MARK: - Utility Methods
    func setDownloadingState(for rowIndex: Int, downloadState: DownloadState) {
        if rowIndex < audioFiles.count {
            audioFiles[rowIndex].downloadState = downloadState
        }
    }
    
    func getAudioFiles() -> [AudioFile] {
        return audioFiles
    }
}
