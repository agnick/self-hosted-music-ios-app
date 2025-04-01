import Foundation

protocol CloudDataManager {
    func fetchRemoteAudioFiles() async throws -> [RemoteAudioFile]
    func downloadAudioFile(_ remote: RemoteAudioFile) async throws -> URL
    func deleteAudioFile(_ remote: RemoteAudioFile) async throws
}
