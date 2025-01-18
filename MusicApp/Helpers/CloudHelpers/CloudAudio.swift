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
    
    func downloadAudioFile(for service: CloudServiceType, urlstring: String, fileName: String) async -> URL? {
        await cloudAudio
            .downloadAudioFile(for: service, urlstring: urlstring, fileName: fileName)
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
    
    func downloadAudioFile(for service: CloudServiceType, urlstring: String, fileName: String) async -> URL? {
        guard let worker = cloudWorkerService.getWorker(for: service) else {
            return nil
        }
        
        guard var request = worker.getDownloadRequest(urlstring: urlstring) else {
            return nil
        }
        
        request.httpMethod = "GET"
                
        do {
            let (data, response) = try await URLSession.shared.data(
                for: request
            )
            
                if let response = response as? HTTPURLResponse {
                    // Проверяем Content-Type
                    if let contentType = response.value(
                        forHTTPHeaderField: "Content-Type"
                    ),
                       !contentType.contains("audio") {
                        print("Invalid file type: \(contentType)")
                        return nil
                    }
                
                
                if response.statusCode == 200 {
                    print("download finished")
                    let documentsUrl = try! FileManager.default.url(
                        for: .documentDirectory,
                        in: .userDomainMask,
                        appropriateFor: nil,
                        create: false
                    )
                    let destinationUrl = documentsUrl.appendingPathComponent(
                        fileName
                    )
                    print(destinationUrl)
                    
                    if FileManager().fileExists(atPath: destinationUrl.path) {
                        print(
                            "File already exists [\(destinationUrl.path)], removing it."
                        )
                        try FileManager.default.removeItem(at: destinationUrl)
                    }
                    
                    try! data.write(to: destinationUrl)
                    return destinationUrl
                }
            }
        } catch {
            print("Error downloading file: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func setDownloadingState(for rowIndex: Int, isDownloading: Bool) {
        if rowIndex < audioFiles.count {
            audioFiles[rowIndex].isDownloading = isDownloading
        }
    }
    
    // MARK: - Utility Methods
    func getAudioFiles() -> [AudioFile] {
        return audioFiles
    }
}
