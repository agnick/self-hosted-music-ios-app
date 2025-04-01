import UIKit

final class CloudAuthService {
    // MARK: - Current cloud service
    private(set) var currentService: RemoteAudioSource?
    
    // MARK: - Cloud auth managers
    private let googleAuth: CloudAuthManager
    private let dropboxAuth: CloudAuthManager
    
    // MARK: - Lifecycle
    init(googleAuth: CloudAuthManager, dropboxAuth: CloudAuthManager) {
        self.googleAuth = googleAuth
        self.dropboxAuth = dropboxAuth
    }
    
    // MARK: - Auth methods
    func authorize(_ service: RemoteAudioSource, from vc: UIViewController?
        ) async throws {
        switch service {
        case .googleDrive:
            try await googleAuth.authorize(vc: vc)
        case .dropbox:
            try await dropboxAuth.authorize(vc: vc)
        }
            
        currentService = service
    }
    
    func reauthorize(_ service: RemoteAudioSource) async throws {
        switch service {
        case .googleDrive:
            try await googleAuth.reauthorize()
        case .dropbox:
            try await dropboxAuth.reauthorize()
        }
        
        currentService = service
    }
    
    func logout(_ service: RemoteAudioSource) async throws {
        switch service {
        case .googleDrive:
            try await googleAuth.logout()
        case .dropbox:
            try await dropboxAuth.logout()
        }
        
        if currentService == service {
            currentService = nil
        }
    }
}
