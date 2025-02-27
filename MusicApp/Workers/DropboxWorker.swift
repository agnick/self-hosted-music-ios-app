//
//  DropboxWorker.swift
//  MusicApp
//
//  Created by Никита Агафонов on 08.01.2025.
//

import SwiftyDropbox
import UIKit

final class DropboxWorker: CloudWorkerProtocol {
    private var authObserver: NSObjectProtocol?
    
    deinit {
        if let observer = authObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func authorize(vc: UIViewController?) async throws {
        guard let vc = vc else {
            throw NSError(
                domain: "UIViewController is required for Dropbox authorization",
                code: 400
            )
        }
        
        let scopeRequest = ScopeRequest(
            scopeType: .user,
            scopes: ["account_info.read", "files.metadata.read", "files.content.read", "files.content.write"],
            includeGrantedScopes: false
        )
        
        return try await withCheckedThrowingContinuation { (
            continuation: CheckedContinuation<Void,
            Error>
        ) in
            DispatchQueue.main.async { [weak self] in
                guard
                    let self = self
                else {
                    continuation.resume(throwing: NSError(
                        domain: "DropboxAuth",
                        code: 500,
                        userInfo: [NSLocalizedDescriptionKey: "Self is nil"]
                        )
                    )
                    return
                }
                
                if let observer = self.authObserver {
                    NotificationCenter.default.removeObserver(observer)
                }
                
                self.authObserver = NotificationCenter.default.addObserver(
                    forName: NSNotification.Name("DropboxAuthCompleted"),
                    object: nil,
                    queue: nil
                ) { notification in
                    if let observer = self.authObserver {
                        NotificationCenter.default.removeObserver(observer)
                        self.authObserver = nil
                    }
                                        
                    if let userInfo = notification.userInfo,
                       let errorMessage = userInfo["error"] as? String {
                        print("Dropbox authorization failed or was canceled:\(errorMessage)")
                        continuation.resume(throwing: NSError(
                            domain: "DropboxAuth",
                            code: 401,
                            userInfo: [NSLocalizedDescriptionKey: errorMessage]
                        ))
                        
                        return
                    }
                                        
                    if DropboxClientsManager.authorizedClient != nil {
                        print("Dropbox authorization completed successfully")
                        
                        continuation.resume(returning: ())
                    } else {
                        print("Dropbox authorization failed: no authorized client")
                        continuation.resume(throwing: NSError(
                            domain: "DropboxAuth",
                            code: 401,
                            userInfo: [NSLocalizedDescriptionKey: "Authorization failed"]
                        ))
                    }
                }
                
                DropboxClientsManager.authorizeFromControllerV2(
                    UIApplication.shared,
                    controller: vc,
                    loadingStatusDelegate: nil,
                    openURL: {
                        url in UIApplication.shared
                            .open(url, options: [:], completionHandler: nil)
                    },
                    scopeRequest: scopeRequest
                )
            }
        }
    }
    
    func fetchAudio() async throws -> [AudioFile] {
        guard let client = DropboxClientsManager.authorizedClient else {
            throw NSError(domain: "DropboxAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authorized"])
        }
        
        var audioFiles: [AudioFile] = []
        
        print("Fetching audio files from Dropbox...")
        do {
            let response = try await client.files.listFolder(path: "").response()
            
            for entry in response.entries {
                guard
                    let pathToFile = entry.pathDisplay,
                    let fileEntry = entry as? Files.FileMetadata
                else {
                    continue
                }
                
                let tempLink = try await client.files.getTemporaryLink(path: pathToFile).response()
                
                let audioFile = AudioFile(
                    name: fileEntry.name,
                    artistName: fileEntry.name,
                    sizeInMB: Double(fileEntry.size) / (1024 * 1024),
                    durationInSeconds: 0,
                    downloadPath: pathToFile,
                    playbackUrl: tempLink.link,
                    source: .dropbox
                )
                
                audioFiles.append(audioFile)
            }
        } catch {
            print(error)
        }
        
        return audioFiles
    }
    
    func reauthorize() async throws {
        guard
            let token = DropboxClientsManager.authorizedClient?.accessTokenProvider.accessToken
        else {
            throw NSError(domain: "Token not found", code: 404)
        }
    
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.main.async {
                DropboxClientsManager.reauthorizeClient(token)
                
                if DropboxClientsManager.authorizedClient != nil {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: NSError(domain: "DropboxAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Reauthorization failed"]))
                }
            }
        }
    }
    
    func logout() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.main.async {
                DropboxClientsManager.unlinkClients()
                
                if DropboxClientsManager.authorizedClient == nil {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: NSError(domain: "DropboxAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Logout failed"]))
                }
            }
        }
        
    }
    
    func downloadAudioFile(from pathToFile: String, fileName: String) async throws -> URL? {
        guard let client = DropboxClientsManager.authorizedClient else {
            throw NSError(domain: "DropboxAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authorized"])
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
        
        do {
            let response = try await client.files.download(path: pathToFile, overwrite: true, destination: destinationUrl).response()
            
            print(response)
            return destinationUrl
        } catch {
            print(error)
            throw error
        }
    }
    
    func deleteAudioFile(from path: String) async throws {
        guard let client = DropboxClientsManager.authorizedClient else {
            throw NSError(domain: "DropboxAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authorized"])
        }
        
        do {
            let response = try await client.files.deleteV2(path: path).response()
            
            print(response)
        } catch {
            print(error)
            return
        }
    }
    
    func getAccessToken() async throws -> String {
        guard
            let token = DropboxClientsManager.authorizedClient?.accessTokenProvider.accessToken
        else {
            throw NSError(domain: "Token not found", code: 404)
        }
        
        return token
    }
}
