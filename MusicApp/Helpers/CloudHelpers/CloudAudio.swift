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
    func fetchAudioFiles(for service: CloudServiceType, forceRefresh: Bool = false) async throws -> [AudioFile] {
        return try await cloudAudio.fetchFiles(for: service, forceRefresh: forceRefresh)
    }
    
    func downloadAudioFile(for service: CloudServiceType, urlstring: String, fileName: String) async throws -> URL {
        return try await cloudAudio.downloadAudioFile(for: service, urlstring: urlstring, fileName: fileName)
    }
    
    func setDownloadingState(for rowIndex: Int, isDownloading: Bool) {
        return cloudAudio.setDownloadingState(for: rowIndex, isDownloading: isDownloading)
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
        forceRefresh: Bool = false
    ) async throws -> [AudioFile] {
        guard let worker = cloudWorkerService.getWorker(for: service) else {
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
    
    func downloadAudioFile(for service: CloudServiceType, urlstring: String, fileName: String) async throws -> URL {
        guard let worker = cloudWorkerService.getWorker(for: service) else {
            throw NSError(domain: "Worker not found", code: 404)
        }
        
        guard var request = worker.getDownloadRequest(urlstring: urlstring) else {
            throw NSError(domain: "Invalid download URL", code: 400, userInfo: nil)
        }
        
        request.httpMethod = "GET"
                
        do {
            let (data, response) = try await URLSession.shared.data(
                for: request
            )
            
            guard let response = response as? HTTPURLResponse else {
                throw NSError(domain: "Invalid response", code: 500, userInfo: nil)
            }
            
            guard response.statusCode == 200 else {
                throw NSError(domain: "HTTP Error", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed with status code: \(response.statusCode)"])
            }
            
            if let contentType = response.value(forHTTPHeaderField: "Content-Type"), !contentType.contains("audio") {
                throw NSError(domain: "Invalid file type", code: 415, userInfo: [NSLocalizedDescriptionKey: "Expected audio file, but got \(contentType)"])
            }
            
            let documentsUrl = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            let destinationUrl = documentsUrl.appendingPathComponent(
                fileName
            )
            
            if FileManager().fileExists(atPath: destinationUrl.path) {
                print(
                    "File already exists [\(destinationUrl.path)], removing it."
                )
                try FileManager.default.removeItem(at: destinationUrl)
            }
            
            try! data.write(to: destinationUrl)
            print("Download finished: \(destinationUrl)")
            
            return destinationUrl
        } catch {
            print("Error downloading file: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Utility Methods
    func setDownloadingState(for rowIndex: Int, isDownloading: Bool) {
        if rowIndex < audioFiles.count {
            audioFiles[rowIndex].isDownloading = isDownloading
        }
    }
    
    func getAudioFiles() -> [AudioFile] {
        return audioFiles
    }
}
