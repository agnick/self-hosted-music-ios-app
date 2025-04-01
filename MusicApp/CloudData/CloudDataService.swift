import Foundation

final class CloudDataService {
    // MARK: - Data managers
    private let googleDataManager: CloudDataManager
    private let dropboxDataManager: CloudDataManager
    
    // MARK: - Auth service
    private let cloudAuthService: CloudAuthService

    // MARK: - Lifecycle
    init(
        googleDataManager: CloudDataManager,
        dropboxDataManager: CloudDataManager,
        cloudAuthService: CloudAuthService
    ) {
        self.googleDataManager = googleDataManager
        self.dropboxDataManager = dropboxDataManager
        self.cloudAuthService = cloudAuthService
    }

    // MARK: - Data methods
    func fetchFiles() async throws -> [RemoteAudioFile] {
        let mgr = try currentManager()
        return try await mgr.fetchRemoteAudioFiles()
    }

    func download(_ audioFile: RemoteAudioFile) async throws -> URL {
        let mgr = try currentManager()
        return try await mgr.downloadAudioFile(audioFile)
    }

    func delete(_ audioFile: RemoteAudioFile) async throws {
        let mgr = try currentManager()
        try await mgr.deleteAudioFile(audioFile)
    }
    
    // MARK: - Utility methods
    private func manager(for service: RemoteAudioSource) -> CloudDataManager {
        switch service {
        case .googleDrive:
            return googleDataManager
        case .dropbox:
            return dropboxDataManager
        }
    }

    private func currentManager() throws -> CloudDataManager {
        guard let service = cloudAuthService.currentService else {
            throw CloudDataError.invalidResponse
        }
        
        return manager(for: service)
    }
}

