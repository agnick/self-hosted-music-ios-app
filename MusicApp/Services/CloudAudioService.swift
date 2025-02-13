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
    
    func downloadAudioFile(for service: CloudServiceType, urlstring: String, fileName: String) async throws -> URL {
        guard let worker = cloudAuthService.getWorker(for: service) else {
            throw NSError(domain: "Worker not found", code: 404)
        }
        
        guard var request = await worker.getDownloadRequest(urlstring: urlstring) else {
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
