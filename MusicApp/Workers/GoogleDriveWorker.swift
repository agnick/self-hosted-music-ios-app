//
//  GoogleDriveWorker.swift
//  MusicApp
//
//  Created by Никита Агафонов on 08.01.2025.
//

import GoogleSignIn
import GoogleAPIClientForREST
import AVFoundation

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
        
        for file in files {
            guard let name = file.name,
                  let webContentLink = file.webContentLink,
                  let fileSize = file.size?.doubleValue,
                  let url = URL(string: webContentLink) else {
                continue
            }
            
            let audioFile = AudioFile(
                name: name,
                url: url,
                sizeInMB: fileSize / (1024 * 1024),
                durationInSeconds: nil,
                artistName: name,
                source: .googleDrive
            )
            
            audioFiles.append(audioFile)
        }
        
        return audioFiles
    }
    
    func getAccessToken() async throws -> String {
        guard let accessToken = GIDSignIn.sharedInstance.currentUser?.authentication.accessToken else {
            throw NSError(domain: "Token not found", code: 404)
        }
        
        return accessToken
    }
    
    func getDownloadRequest(urlstring: String) async -> URLRequest? {
        let fileId = extractFileId(
            from: urlstring
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
    
    // MARK: - Private methods
    func extractFileId(from url: String) -> String? {
        let regex = try! NSRegularExpression(
            pattern: "id=([a-zA-Z0-9_-]+)",
            options: []
        )
        
        let range = NSRange(location: 0, length: url.utf16.count)
        if let match = regex.firstMatch(in: url, options: [], range: range) {
            if let idRange = Range(match.range(at: 1), in: url) {
                return String(url[idRange])
            }
        }
        
        return nil
    }
}
