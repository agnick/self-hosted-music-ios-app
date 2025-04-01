import Foundation
import UIKit
import CoreData
import AVFoundation

final class AudioImportWorker: AudioImportWorkerProtocol {
    // MARK: - Dependencies
    private let coreDataManager: CoreDataManager
    
    // MARK: - Lifecycle
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Copy Files to App Folder
    func copyFilesToAppFolder(files: [URL]) async throws {
        let fileManager = FileManager.default
        let documentsDirectory = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let context = coreDataManager.context
        
        for fileURL in files {
            let destinationURL = documentsDirectory.appendingPathComponent(fileURL.lastPathComponent)
            
            // Copy to disk
            if !fileManager.fileExists(atPath: destinationURL.path) {
                let access = fileURL.startAccessingSecurityScopedResource()
                
                defer {
                    if access { fileURL.stopAccessingSecurityScopedResource()
                    }
                }
                
                let data = try Data(contentsOf: fileURL)
                try data.write(to: destinationURL)
            }
            
            // Calculate audio duration.
            let asset = AVURLAsset(url: destinationURL)
            let durationTime = try await asset.load(.duration)
            let duration = CMTimeGetSeconds(durationTime)
            
            // Get File size.
            let fileSizeBytes = try fileManager.attributesOfItem(atPath: destinationURL.path)[.size] as? Int64 ?? 0
            let sizeInMB = Double(fileSizeBytes) / (1024 * 1024)
            
            // Try to find existing entity in Core Data.
            let fetchRequest: NSFetchRequest<DownloadedAudioFileEntity> = DownloadedAudioFileEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "downloadPath == %@", destinationURL.path)

            let existing = try context.fetch(fetchRequest)
            let entity: DownloadedAudioFileEntity
            
            if let first = existing.first {
                entity = first
            } else {
                entity = DownloadedAudioFileEntity(context: context)
                entity.id = UUID()
                entity.downloadPath = destinationURL.path
            }
            
            // Update all field.
            entity.name = destinationURL.lastPathComponent
            entity.artistName = destinationURL.deletingPathExtension().lastPathComponent
            entity.playbackUrl = destinationURL.absoluteString
            entity.sizeInMB = sizeInMB
            entity.durationInSeconds = duration
            entity.downloadStateRaw = RemoteDownloadState.downloaded.rawValue
            entity.image = UIImage(image: .icAudioImgSvg).pngData()

            do {
                try coreDataManager.saveContext()
            } catch {
                throw CloudDataError.saveFailed(error)
            }
        }
    }
}
