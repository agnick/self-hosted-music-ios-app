//
//  LocalAudioWorker.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.01.2025.
//

import Foundation
import AVFoundation

final class LocalAudioWorker {
    // MARK: - Variables
    private let documentsDirectory: URL
    
    // MARK: - Lifecycle
    init() {
        do {
            documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch {
            fatalError("Could not locate the documents directory: \(error)")
        }
    }
    
    // MARK: - Fetch Saved Files
    func getSavedAudioFiles() async throws -> [AudioFile] {
        var audioFiles: [AudioFile] = []
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            
            for file in files where file.pathExtension == "mp3" || file.pathExtension == "wav" {
                do {
                    let attributes = try fileManager.attributesOfItem(atPath: file.path)
                    let fileSize = attributes[.size] as? Double ?? 0
                    
                    let asset = AVURLAsset(url: file)
                    let duration = try await asset.load(.duration)
                    let durationInSeconds = CMTimeGetSeconds(duration)
                    
                    let audioFile = AudioFile(
                        name: file.lastPathComponent,
                        artistName: file.lastPathComponent,
                        sizeInMB: fileSize / (1024 * 1024),
                        durationInSeconds: durationInSeconds.isNaN ? 0 : durationInSeconds,
                        downloadPath: file.path,
                        playbackUrl: file.absoluteString,
                        downloadState: .downloaded,
                        source: .local
                    )
                    
                    audioFiles.append(audioFile)
                } catch {
                    print("Skipping file due to processing error: \(file.lastPathComponent), \(error.localizedDescription)")
                    continue
                }
            }
        } catch {
            print("Error fetching files from directory: \(error.localizedDescription)")
            throw error
        }
        
        return audioFiles
    }
    
    func deleteAudioFile(filePath: String) throws {
        let fileURL = URL(fileURLWithPath: filePath)
        let fileManager = FileManager.default
        
        try fileManager.removeItem(at: fileURL)
    }
}
