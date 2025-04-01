import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

final class GoogleDriveAuthManager: CloudAuthManager {
    // MARK: - Variables
    private let driveService: GTLRDriveService
    
    // MARK: - Lifecycle
    init(driveService: GTLRDriveService) {
        self.driveService = driveService
    }
    
    // MARK: - Auth methods
    func authorize(vc: UIViewController?) async throws {
        let clientID = ENV.GOOGLE_CLIENT_ID
        
        guard
            !clientID.isEmpty
        else {
            throw CloudAuthError.missingClientID
        }
        
        let rootViewController: UIViewController = try await MainActor.run {
            guard
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let rootViewController = windowScene.windows.first?.rootViewController
            else {
                throw CloudAuthError.missingRootViewController
            }
            
            return rootViewController
        }
        
        let scopes = ["https://www.googleapis.com/auth/drive"]
        
        
        
        try await withCheckedThrowingContinuation({ [weak self] (continuation: CheckedContinuation<Void, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                GIDSignIn.sharedInstance.signIn(
                    with: GIDConfiguration(clientID: clientID),
                    presenting: rootViewController,
                    hint: nil,
                    additionalScopes: scopes
                ) { user, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                        
                    guard let authentication = user?.authentication else {
                        continuation.resume(throwing: CloudAuthError.authorizationFailed)
                        return
                    }
                        
                    self.driveService.authorizer = authentication
                            .fetcherAuthorizer()
                    continuation.resume()
                }
            }
        })
    }
    
    func reauthorize() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if let error = error {
                    continuation.resume(throwing: CloudAuthError.restoreFailed)
                    return
                }
                
                guard
                    let user = user
                else {
                    continuation.resume(throwing: CloudAuthError.userNotFound)
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
}
