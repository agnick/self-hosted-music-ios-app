//
//  CloudAuth.swift
//  MusicApp
//
//  Created by Никита Агафонов on 10.01.2025.
//

import UIKit

// MARK: - CloudAuthService
struct CloudAuthService {
    private let cloudAuth = CloudAuth.shared
    
    // MARK: - Public methods
    func authorize(for service: CloudServiceType, vc: UIViewController? = nil) async throws {
        try await cloudAuth.authorize(for: service, vc: vc)
    }
    
    func reauthorize(for service: CloudServiceType) async throws {
        try await cloudAuth.reauthorize(for: service)
    }
    
    func logout(from service: CloudServiceType) async throws {
        try await cloudAuth.logout(from: service)
    }
    
    func isAuthorized(for service: CloudServiceType) -> Bool {
        return cloudAuth.isAuthorized(for: service)
    }
    
    func getWorker(for service: CloudServiceType) -> CloudWorkerProtocol? {
        return cloudAuth.getWorker(for: service)
    }
    
    func getAuthorizedService() -> CloudServiceType? {
        return cloudAuth.getAuthorizedService()
    }
}

// MARK: - CloudAuth
final class CloudAuth {
    // Shared instance.
    static let shared: CloudAuth = CloudAuth()
    
    // MARK: - Variables
    private var authorizedService: CloudServiceType?
    private let workers: [CloudServiceType: CloudWorkerProtocol] = [
        .googleDrive: GoogleDriveWorker(),
        .dropbox: DropboxWorker(),
    ]
    
    // MARK: - Lifecycle
    private init() {}
    
    // MARK: - Authorization methods
    func authorize(for service: CloudServiceType, vc: UIViewController? = nil) async throws {
        guard let worker = workers[service] else {
            throw NSError(domain: "Worker not found", code: 404)
        }
        
        if authorizedService == service {
            return
        }
        
        try await worker.authorize(vc: vc)

        authorizedService = service
    }
    
    func reauthorize(for service: CloudServiceType) async throws {
        guard let worker = workers[service] else {
            throw NSError(domain: "Worker not found", code: 404)
        }
        
        do {
            try await worker.reauthorize()
            authorizedService = service
        } catch {
            throw NSError(domain: "\(service) reauthorization failed", code: 401, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
        }
    }
    
    func logout(from service: CloudServiceType) async throws {
        guard let worker = workers[service] else {
            throw NSError(domain: "Worker not found", code: 404)
        }
        
        try await worker.logout()
        authorizedService = nil
        print("Successfully logged out of \(service.displayName)")
    }
    
    // MARK: - Utility methods
    func isAuthorized(for service: CloudServiceType) -> Bool {
        return authorizedService == service
    }
    
    func getWorker(for service: CloudServiceType) -> CloudWorkerProtocol? {
        return workers[service]
    }
    
    func getAuthorizedService() -> CloudServiceType? {
        return authorizedService
    }
}
