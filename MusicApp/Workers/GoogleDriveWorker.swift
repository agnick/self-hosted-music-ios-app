//
//  GoogleDriveWorker.swift
//  MusicApp
//
//  Created by Никита Агафонов on 08.01.2025.
//

import GoogleSignIn
import GoogleAPIClientForREST
import AVFoundation
import GoogleDriveClient

final class GoogleDriveWorker: CloudWorkerProtocol {
    // MARK: - Variables
    private var driveService = GTLRDriveService()
    
    // MARK: - Public methods
    func authorize(vc: UIViewController?) async throws {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "CLIENT_ID") as? String else {
            throw NSError(domain: "Missing CLIENT_ID in Info.plist", code: 1)
        }
        
        let rootViewController: UIViewController = try await MainActor.run {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootViewController = windowScene.windows.first?.rootViewController else {
                throw NSError(domain: "Unable to find root view controller", code: 3)
                }
            
            return rootViewController
        }
        
        let scopes = ["https://www.googleapis.com/auth/drive"]
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.main.async {
                GIDSignIn.sharedInstance
                    .signIn(
                        with: GIDConfiguration(clientID: clientID),
                        presenting: rootViewController,
                        hint: nil,
                        additionalScopes: scopes
                    ) {
                        user,
                        error in
                        if let error = error {
                            continuation.resume(throwing: error)
                            return
                        }
                        
                        guard let authentication = user?.authentication else {
                            continuation.resume(throwing: NSError(domain: "Authorization failed", code: 3, userInfo: nil))
                            return
                        }
                        
                        self.driveService.authorizer = authentication
                            .fetcherAuthorizer()
                        continuation.resume()
                    }
            }
        }
    }
    
    func reauthorize() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let user = user else {
                    continuation.resume(throwing: NSError(domain: "User not found", code: 404))
                    return
                }
                
                self.driveService.authorizer = user.authentication
                    .fetcherAuthorizer()
                continuation.resume()
            }
        }
    }
    
    func logout() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            GIDSignIn.sharedInstance.signOut()
            driveService.authorizer = nil
            continuation.resume()
        }
    }
    
    func fetchAudio() async throws -> [AudioFile] {
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "mimeType contains 'audio/' and trashed = false"
        query.fields = "files(id, name, webContentLink, size, videoMediaMetadata(durationMillis))"
        
        let result: GTLRDrive_FileList = try await withCheckedThrowingContinuation { continuation in
            driveService.executeQuery(query) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let fileList = result as? GTLRDrive_FileList else {
                    continuation
                        .resume(
                            throwing: NSError(
                                domain: "FetchAudioError",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Invalid response"]
                            )
                        )
                    return
                }
                
                continuation.resume(returning: fileList)
            }
        }
        
        guard let files = result.files else {
            return []
        }
        
        var audioFiles: [AudioFile] = []
        
        try await withThrowingTaskGroup(of: AudioFile?.self) { group in
            for file in files {
                group.addTask {
                    do {
                        guard
                            let webContentLink = file.webContentLink,
                            let url = URL(string: webContentLink)
                        else {
                            throw NSError(domain: "Invalid URL", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid web content link"])
                        }
                        
                        let asset = AVURLAsset(url: url)
                        let duration = try await asset.load(.duration)
                        let durationInSeconds = CMTimeGetSeconds(duration)
                        
                        let fileSize = file.size?.doubleValue ?? 0
                        let fileName = file.name ?? "Unknown"
                        
                        return AudioFile(
                            name: fileName,
                            artistName: fileName,
                            sizeInMB: fileSize / (1024 * 1024),
                            durationInSeconds: durationInSeconds,
                            downloadPath: webContentLink,
                            playbackUrl: webContentLink,
                            source: .googleDrive
                        )
                    } catch {
                        print("Ошибка при обработке \(file.name ?? "Unknown"): \(error)")
                        return nil
                    }
                }
            }
            
            for try await audioFile in group {
                if let audioFile = audioFile {
                    audioFiles.append(audioFile)
                }
            }
        }
        
        return audioFiles
    }
    
    func downloadAudioFile(from urlString: String, fileName: String) async throws -> URL? {
        guard var request = await getDownloadRequest(from: urlString) else {
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
            
            try data.write(to: destinationUrl)
            print("Download finished: \(destinationUrl)")
            
            return destinationUrl
        } catch {
            print("Error downloading file: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteAudioFile(from urlString: String) async throws {
        guard
            let fileId = extractFileId(from: urlString)
        else {
            throw NSError(
                domain: "GoogleDriveWorker",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Не удалось извлечь идентификатор файла из URL"]
            )
        }
        
        let query = GTLRDriveQuery_FilesDelete.query(withFileId: fileId)
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            driveService.executeQuery(query) { _, _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    print("Файл \(fileId) успешно удален")
                    continuation.resume()
                }
            }
        }
    }
    
    func getAccessToken() async throws -> String {
        guard let accessToken = GIDSignIn.sharedInstance.currentUser?.authentication.accessToken else {
            throw NSError(domain: "Token not found", code: 404)
        }
        
        return accessToken
    }
    
    // MARK: - Private methods
    private func extractFileId(from url: String) -> String? {
        guard
            let regex = try? NSRegularExpression(
                pattern: "id=([a-zA-Z0-9_-]+)",
                options: []
            )
        else {
            return nil
        }
                
        
        let range = NSRange(location: 0, length: url.utf16.count)
        if let match = regex.firstMatch(in: url, options: [], range: range) {
            if let idRange = Range(match.range(at: 1), in: url) {
                return String(url[idRange])
            }
        }
        
        return nil
    }
    
    private func getDownloadRequest(from urlString: String) async -> URLRequest? {
        let fileId = extractFileId(
            from: urlString
        )
        
        guard let fileId = fileId else {
            print("Invalid file ID")
            return nil
        }
        
        let apiUrl = "https://www.googleapis.com/drive/v3/files/\(fileId)?alt=media"
        var request = URLRequest(url: URL(string: apiUrl)!)
        
        if let accessToken = try? await getAccessToken() {
            request
                .addValue(
                    "Bearer \(accessToken)",
                    forHTTPHeaderField: "Authorization"
                )
        }
        
        return request
    }
}
