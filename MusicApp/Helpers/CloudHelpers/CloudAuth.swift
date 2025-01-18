//
//  CloudAuth.swift
//  MusicApp
//
//  Created by Никита Агафонов on 10.01.2025.
//

import Foundation

// MARK: - CloudAuthService
struct CloudAuthService {
    private let cloudAuth = CloudAuth.shared
    
    // MARK: - Public methods
    func authorize(
        for service: CloudServiceType,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        cloudAuth.authorize(for: service, completion: completion)
    }
    
    func reauthorize(for service: CloudServiceType, completion: @escaping (Result<Void, Error>) -> Void) {
        cloudAuth.reauthorize(for: service, completion: completion)
    }
    
    func logout(from service: CloudServiceType, completion: @escaping (Result<Void, Error>) -> Void) {
        cloudAuth.logout(from: service, completion: completion)
    }
    
    func isAuthorized(for service: CloudServiceType) -> Bool {
        return cloudAuth.isAuthorized(for: service)
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
    private let cloudWorkerService: CloudWorkerService = CloudWorkerService()
    
    // MARK: - Lifecycle
    private init() {}
    
    // MARK: - Authorization methods
    func authorize(
        for service: CloudServiceType,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let worker = cloudWorkerService.getWorker(for: service) else {
            completion(.failure(NSError(domain: "Worker not found", code: 404)))
            return
        }
        
        if authorizedService == service {
            completion(.success(()))
            return
        }
        
        worker.authorize { [weak self] result in
            switch result {
            case .success:
                self?.authorizedService = service
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func reauthorize(
        for service: CloudServiceType,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let worker = cloudWorkerService.getWorker(for: service) else {
            completion(.failure(NSError(domain: "Worker not found", code: 404)))
            return
        }
        
        worker.reauthorize { [weak self] result in
            switch result {
            case .success:
                self?.authorizedService = service
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func logout(from service: CloudServiceType, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let worker = cloudWorkerService.getWorker(for: service) else {
            completion(.failure(NSError(domain: "Worker not found", code: 404)))
            return
        }
        
        worker.logout { [weak self] result in
            switch result {
            case .success:
                self?.authorizedService = nil
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Utility methods
    func isAuthorized(for service: CloudServiceType) -> Bool {
        return authorizedService == service
    }
    
    func getAuthorizedService() -> CloudServiceType? {
        return authorizedService
    }
}
