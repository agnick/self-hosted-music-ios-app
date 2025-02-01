//
//  LocalAudioService.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.01.2025.
//

final class LocalAudioService {
    // MARK: - Variables
    private var localAudioFiles: [AudioFile] = []
    private let localAudioWorker: LocalAudioWorker = LocalAudioWorker()
    
    // MARK: - File Fetching
    func getSavedAudioFiles() async throws -> [AudioFile] {
        do {
            localAudioFiles = try await localAudioWorker.getSavedAudioFiles()
            return localAudioFiles
        } catch {
            print("Error fetching local audio files: \(error.localizedDescription)")
            throw error
        }
    }
}
