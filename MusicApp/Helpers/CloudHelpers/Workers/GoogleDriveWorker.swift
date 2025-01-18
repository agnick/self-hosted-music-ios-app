//
//  GoogleDriveWorker.swift
//  MusicApp
//
//  Created by Никита Агафонов on 08.01.2025.
//

import GoogleSignIn
import GoogleAPIClientForREST

final class GoogleDriveWorker: CloudWorkerProtocol {
    // MARK: - Variables
    private var driveService = GTLRDriveService()
    
    // MARK: - Public methods
    func authorize(
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "CLIENT_ID") as? String else {
            completion(
                .failure(
                    NSError(domain: "Missing CLIENT_ID in Info.plist", code: 1)
                )
            )
            return
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            completion(
                .failure(
                    NSError(
                        domain: "Unable to find root view controller",
                        code: 3,
                        userInfo: nil
                    )
                )
            )
            return
        }
        
        let scopes = ["https://www.googleapis.com/auth/drive"]
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
                    completion(.failure(error))
                    return
                }
            
                guard let authentication = user?.authentication else {
                    completion(
                        .failure(
                            NSError(
                                domain: "Authorization failed",
                                code: 3,
                                userInfo: nil
                            )
                        )
                    )
                    return
                }
            
                self.driveService.authorizer = authentication
                    .fetcherAuthorizer()
                completion(.success(()))
            }
    }
    
    func getAccessToken(completion: @escaping (Result<String, any Error>) -> Void) {
        guard let accessToken = GIDSignIn.sharedInstance.currentUser?.authentication.accessToken else {
            completion(.failure(NSError(domain: "Token not found", code: 404)))
            return
        }
        
        completion(.success(accessToken))
    }
    
    func reauthorize(completion: @escaping (Result<Void, any Error>) -> Void) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = user else {
                completion(.failure(NSError(domain: "User not found", code: 404)))
                return
            }
            
            self.driveService.authorizer = user.authentication.fetcherAuthorizer()
            completion(.success(()))
        }
    }
    
    func logout(completion: @escaping (Result<Void, any Error>) -> Void) {
        GIDSignIn.sharedInstance.signOut()
        driveService.authorizer = nil
        completion(.success(()))
    }
    
    func fetchAudio(
        completion: @escaping (
            Result<[AudioFile], Error>
        ) -> Void
    ) {
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "mimeType contains 'audio/' and trashed = false"
        query.fields = "files(id, name, webContentLink, size)"
        
        driveService.executeQuery(query) { _, result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let fileList = result as? GTLRDrive_FileList,
                  let files = fileList.files else {
                completion(.success([]))
                return
            }
            
            let audioFiles = files.compactMap { file -> AudioFile? in
                guard let name = file.name, let webContentLink = file.webContentLink, let fileSize = file.size?.doubleValue else {
                    return nil
                }
                
                let url = URL(string: webContentLink)!
                
                return AudioFile(name: name, url: url, sizeInMB: fileSize / (1024 * 1024), durationInSeconds: 0, artistName: nil)
            }
            
            completion(.success(audioFiles))
        }
    }
    
    func getDownloadRequest(urlstring: String) -> URLRequest? {
        let fileId = extractFileId(
            from: urlstring
        )
        
        guard let fileId = fileId else {
            print("Invalid file ID")
            return nil
        }
        
        let apiUrl = "https://www.googleapis.com/drive/v3/files/\(fileId)?alt=media"
        var request = URLRequest(url: URL(string: apiUrl)!)
        
        if let accessToken = getAccessToken() {
            request
                .addValue(
                    "Bearer \(accessToken)",
                    forHTTPHeaderField: "Authorization"
                )
        }
        
        return request
    }
    
    // MARK: - Private methods
    private func getAccessToken() -> String? {
        return GIDSignIn.sharedInstance.currentUser?.authentication.accessToken
    }
    
    private func extractFileId(from url: String) -> String? {
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
