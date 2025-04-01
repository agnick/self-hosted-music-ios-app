import Foundation
import AVFoundation
import CoreData
import SwiftyDropbox

final class DropboxDataManager: CloudDataManager {
    // MARK: - Variables
    private let coreDataManager: CoreDataManager
    
    // MARK: - Lifecycle
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    func fetchRemoteAudioFiles() async throws -> [RemoteAudioFile] {
        guard let client = DropboxClientsManager.authorizedClient else {
            throw CloudDataError.serviceUnavailable
        }
        
        // Get file list.
        let response: Files.ListFolderResult
        do {
            response = try await client.files.listFolder(path: "").response()
        } catch {
            throw CloudDataError.serviceUnavailable
        }
        
        let supportedExt = ["mp3", "m4a", "aac", "wav", "flac", "ogg", "alac"]
        var models: [RemoteAudioFile] = []
        let context = coreDataManager.context
        
        for entry in response.entries {
            // Filter audio files.
            guard
                let fileEntry = entry as? Files.FileMetadata,
                let pathToFile = fileEntry.pathDisplay,
                let ext = pathToFile.split(separator: ".").last?.lowercased(),
                supportedExt.contains(ext),
                let temp = try? await client.files.getTemporaryLink(path: pathToFile).response(),
                let url = URL(string: temp.link),
                let uuid = UUID.fromDeterministicHash(of: fileEntry.id)
            else {
                continue
            }
                        
            // Get audio file duration.
            let duration: Double
            do {
                let asset = AVURLAsset(url: url)
                let cmTime = try await asset.load(.duration)
                duration = CMTimeGetSeconds(cmTime)
            } catch {
                throw CloudDataError.decodingFailed
            }
            
            let sizeMB = Double(fileEntry.size) / (1024 * 1024)
            let title = fileEntry.name
            
            // Save or update model in CoreData.
            let fetchReq: NSFetchRequest<RemoteAudioFileEntity> = RemoteAudioFileEntity.fetchRequest()
            fetchReq.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
            let existing = try? context.fetch(fetchReq)
            let entity = existing?.first ?? RemoteAudioFileEntity(context: context)
            
            entity.id = uuid
            entity.sizeInMB = sizeMB
            entity.durationInSeconds = duration
            entity.downloadPath = pathToFile
            entity.playbackUrl = temp.link
            entity.sourceRaw = RemoteAudioSource.dropbox.rawValue
            entity.downloadStateRaw = RemoteDownloadState.notStarted.rawValue
            
            if entity.name == nil || entity.name?.isEmpty == true {
                entity.name = title
            }

            if entity.artistName == nil || entity.artistName?.isEmpty == true {
                entity.artistName = title
            }
            
            var trackImg = UIImage(image: .icAudioImgSvg)
            if let existingImageData = entity.image, let existingImage = UIImage(data: existingImageData) {
                trackImg = existingImage
            }
            
            // Create model.
            let model = RemoteAudioFile(
                id: uuid,
                name: title,
                artistName: title,
                trackImg: trackImg,
                sizeInMB: sizeMB,
                durationInSeconds: duration,
                playbackUrl: temp.link,
                downloadPath: pathToFile,
                downloadState: .notStarted,
                source: .dropbox
            )
            models.append(model)
        }
        
        do {
            try coreDataManager.saveContext()
        } catch {
            throw CloudDataError.saveFailed(error)
        }
        
        return models
    }
    
    func downloadAudioFile(_ remote: RemoteAudioFile) async throws -> URL {
        guard let client = DropboxClientsManager.authorizedClient else {
            throw CloudDataError.serviceUnavailable
        }
        
        // Download file.
        let documents = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let ext = (remote.downloadPath as NSString).pathExtension
        let fileName = "\(remote.id.uuidString).\(ext)"
        let destinationURL = documents.appendingPathComponent(fileName)
        
        do {
            _ = try await client.files.download(
                path: remote.downloadPath,
                overwrite: true,
                destination: destinationURL
            ).response()
        } catch {
            throw CloudDataError.serviceUnavailable
        }
        
        // Save model to Core Data
        let context = coreDataManager.context
        let fetchReq: NSFetchRequest<DownloadedAudioFileEntity> = DownloadedAudioFileEntity.fetchRequest()
        fetchReq.predicate = NSPredicate(format: "id == %@", remote.id as CVarArg)
        let existing = try? context.fetch(fetchReq)
        let entity = existing?.first ?? DownloadedAudioFileEntity(context: context)
        
        entity.id = remote.id
        entity.name = remote.name
        entity.artistName = remote.artistName
        if let data = remote.trackImg.jpegData(compressionQuality: 0.8) {
            entity.image = data
        }
        entity.sizeInMB = remote.sizeInMB
        entity.durationInSeconds = remote.durationInSeconds
        entity.downloadPath = remote.downloadPath
        entity.playbackUrl = destinationURL.absoluteString
        entity.downloadStateRaw = RemoteDownloadState.downloaded.rawValue
        
        do {
            try coreDataManager.saveContext()
        } catch {
            throw CloudDataError.saveFailed(error)
        }
        
        return destinationURL
    }
    
    func deleteAudioFile(_ remote: RemoteAudioFile) async throws {
        guard let client = DropboxClientsManager.authorizedClient else {
            throw CloudDataError.serviceUnavailable
        }
        
        // Delete file from Dropbox.
        do {
            _ = try await client.files.deleteV2(path: remote.downloadPath).response()
        } catch {
            throw CloudDataError.deletionFailed(error)
        }
        
        // Delete model from Core Data.
        let context = coreDataManager.context
        let fetchReq: NSFetchRequest<RemoteAudioFileEntity> = RemoteAudioFileEntity.fetchRequest()
        fetchReq.predicate = NSPredicate(format: "id == %@", remote.id as CVarArg)
        let results = try context.fetch(fetchReq)
        
        guard let entity = results.first else {
            throw CloudDataError.entityNotFound
        }
        
        context.delete(entity)
        
        do {
            try coreDataManager.saveContext()
        } catch {
            throw CloudDataError.saveFailed(error)
        }
    }
}
