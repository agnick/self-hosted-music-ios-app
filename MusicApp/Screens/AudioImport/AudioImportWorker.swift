//
//  AudioImportWorker.swift
//  MusicApp
//
//  Created by Никита Агафонов on 29.01.2025.
//

import Foundation

final class AudioImportWorker {
    // MARK: - Copy Files to App Folder
    func copyFilesToAppFolder(files: [URL]) async throws {
        let fileManager = FileManager.default
        let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        for file in files {
            let destinationURL = documentsDirectory.appendingPathComponent(file.lastPathComponent)
            
            if fileManager.fileExists(atPath: destinationURL.path) {
                print("File already exists: \(destinationURL.lastPathComponent), skipping.")
                continue
            }
            
            let hasAccess = file.startAccessingSecurityScopedResource()
            
            do {
                if hasAccess {
                    defer { file.stopAccessingSecurityScopedResource() }

                    let fileData = try Data(contentsOf: file)
                    try fileData.write(to: destinationURL)

                    print("Copied file: \(file.lastPathComponent) to \(destinationURL.path)")
                } else {
                    print("No permission to access file: \(file.lastPathComponent)")
                    throw NSError(domain: "com.MusicApp.import", code: 403, userInfo: [NSLocalizedDescriptionKey: "No permission to access file"])
                }
            } catch {
                print("Failed to copy file: \(file.lastPathComponent), error: \(error.localizedDescription)")
                throw error
            }
        }
    }
}
