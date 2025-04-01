import UIKit
import SwiftyDropbox

final class DropboxAuthManager: CloudAuthManager {
    // MARK: - Variables
    private var authObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle
    deinit {
        if let observer = authObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Authorization
    func authorize(vc: UIViewController?) async throws {
        guard let vc = vc else {
            throw CloudAuthError.missingRootViewController
        }
        
        return try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<Void, Error>) in
            guard
                let self = self
            else {
                continuation.resume(throwing: CloudAuthError.authorizationFailed)
                return
            }
            
            DispatchQueue.main.async {
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
                        continuation.resume(throwing: CloudAuthError.dropboxError(message: errorMessage))
                        return
                    }
                                        
                    if DropboxClientsManager.authorizedClient != nil {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: CloudAuthError.authorizationFailed)
                    }
                }
                
                let scopeRequest = ScopeRequest(
                    scopeType: .user,
                    scopes: ["account_info.read", "files.metadata.read", "files.content.read", "files.content.write"],
                    includeGrantedScopes: false
                )
                
                DropboxClientsManager.authorizeFromControllerV2(
                    UIApplication.shared,
                    controller: vc,
                    loadingStatusDelegate: nil,
                    openURL: { url in
                        UIApplication.shared.open(url)
                    },
                    scopeRequest: scopeRequest
                )
            }
        }
    }
    
    func reauthorize() async throws {
        guard
            let token = DropboxClientsManager.authorizedClient?.accessTokenProvider.accessToken
        else {
            throw CloudAuthError.userNotFound
        }
    
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.main.async {
                DropboxClientsManager.reauthorizeClient(token)
                
                if DropboxClientsManager.authorizedClient != nil {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: CloudAuthError.restoreFailed)
                }
            }
        }
    }
    
    func logout() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.main.async {
                DropboxClientsManager.unlinkClients()
                
                if DropboxClientsManager.authorizedClient == nil {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: CloudAuthError.logoutFailed)
                }
            }
        }
        
    }
}
