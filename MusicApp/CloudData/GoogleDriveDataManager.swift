import Foundation
import CoreData
import AVFoundation
import GoogleAPIClientForREST
import UniformTypeIdentifiers

final class GoogleDriveDataManager: CloudDataManager {
    // MARK: - Variables
    private let driveService: GTLRDriveService
    private let coreDataManager: CoreDataManager
    
    // MARK: - Lifecycle
    init(driveService: GTLRDriveService, coreDataManager: CoreDataManager) {
        self.driveService = driveService
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Data methods
    func fetchRemoteAudioFiles() async throws -> [RemoteAudioFile] {
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "mimeType contains 'audio/' and trashed = false"
        query.fields = "files(id, name, size, mimeType, webContentLink, permissions)"
        
        let result: GTLRDrive_FileList = try await withCheckedThrowingContinuation { continuation in
            driveService.executeQuery(query) { _, response, error in
                if let _ = error {
                    continuation.resume(throwing: CloudDataError.serviceUnavailable)
                    return
                }
                
                guard
                    let fileList = response as? GTLRDrive_FileList
                else {
                    continuation.resume(throwing: CloudDataError.invalidResponse)
                    return
                }
                
                continuation.resume(returning: fileList)
            }
        }
        
        guard let files = result.files else {
            return []
        }
        
        var models: [RemoteAudioFile] = []
        
        for file in files {
            let isPublic = file.permissions?.contains { $0.type == "anyone" } ?? false
            
            guard
                isPublic,
                let idStr = file.identifier,
                let uuid = UUID.fromDeterministicHash(of: idStr),
                let webLink = file.webContentLink,
                let url = URL(string: webLink)
            else {
                continue
            }
                        
            let durationSeconds: Double
            do {
                let asset = AVURLAsset(url: url)
                let duration = try await asset.load(.duration)
                durationSeconds = CMTimeGetSeconds(duration)
            } catch {
                throw CloudDataError.decodingFailed
            }
            
            let sizeMB = (file.size?.doubleValue ?? 0) / (1024 * 1024)
            let title = file.name ?? "Без названия"
            
            // Save to Core Data.
            let context = coreDataManager.context
            let request: NSFetchRequest<RemoteAudioFileEntity> = RemoteAudioFileEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
            let existing = (try? context.fetch(request))?.first
            
            let entity = existing ?? RemoteAudioFileEntity(context: context)
            entity.id = uuid
            entity.sizeInMB = sizeMB
            entity.durationInSeconds = durationSeconds
            entity.downloadPath = webLink
            entity.playbackUrl = webLink
            entity.downloadStateRaw = RemoteDownloadState.notStarted.rawValue
            entity.sourceRaw = RemoteAudioSource.googleDrive.rawValue
            
            if entity.name == nil || entity.name?.isEmpty == true {
                entity.name = title
            }
            
            if entity.artistName == nil || entity.artistName?.isEmpty == true {
                entity.artistName = title
            }
            
            // Creating model to return.
            let model = RemoteAudioFile(
                id: uuid,
                name: title,
                artistName: title,
                trackImg: UIImage(image: .icAudioImgSvg),
                sizeInMB: sizeMB,
                durationInSeconds: durationSeconds,
                playbackUrl: webLink,
                downloadPath: webLink,
                downloadState: .notStarted,
                source: .googleDrive
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
        guard let url = URL(string: remote.downloadPath) else {
            throw CloudDataError.invalidURL
        }
        
        // Make request.
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw CloudDataError.serviceUnavailable
        }
        
        // HTTP response check.
        guard let http = response as? HTTPURLResponse else {
            throw CloudDataError.invalidResponse
        }
        
        guard http.statusCode == 200 else {
            throw CloudDataError.httpError(http.statusCode)
        }
        
        if let contentType = http.value(forHTTPHeaderField: "Content-Type"), !contentType.contains("audio") {
            throw CloudDataError.invalidContentType(contentType)
        }
        
        // Save to documents.
        let documents = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let pathExt = (remote.downloadPath as NSString).pathExtension
        let headerExt = extFromMime(http.value(forHTTPHeaderField: "Content-Type"))
        
        let ext: String
        if !pathExt.isEmpty {
            ext = pathExt
        } else if !headerExt.isEmpty {
            ext = headerExt
        } else {
            ext = "mp3"
        }
        
        let fileName = "\(remote.id.uuidString).\(ext)"
        let destinationUrl = documents.appendingPathComponent(fileName)
        
        // Delete old file if exists.
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            do {
                try FileManager.default.removeItem(at: destinationUrl)
            } catch {
                throw CloudDataError.fileOperationFailed(error)
            }
        }
        
        // Write new file.
        do {
            try data.write(to: destinationUrl)
        } catch {
            throw CloudDataError.fileOperationFailed(error)
        }
        
        // Create or updata data in Core Data.
        let context = coreDataManager.context
        let request: NSFetchRequest<DownloadedAudioFileEntity> = DownloadedAudioFileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", remote.id as CVarArg)
        let existing = (try? context.fetch(request))?.first
        
        let entity = existing ?? DownloadedAudioFileEntity(context: context)
        entity.id = remote.id
        entity.name = remote.name
        entity.artistName = remote.artistName
        
        if let imageData = remote.trackImg.jpegData(compressionQuality: 0.8) {
            entity.image = imageData
        }
        
        entity.sizeInMB = remote.sizeInMB
        entity.durationInSeconds = remote.durationInSeconds
        entity.downloadPath = remote.downloadPath
        entity.playbackUrl = destinationUrl.absoluteString
        entity.downloadStateRaw = RemoteDownloadState.downloaded.rawValue
        
        do {
            try coreDataManager.saveContext()
        } catch {
            throw CloudDataError.saveFailed(error)
        }
        
        return destinationUrl
    }
    
    func deleteAudioFile(_ remote: RemoteAudioFile) async throws {
        // Delete file from Google Drive.
        let fileID = remote.id.uuidString
        let deleteQuery = GTLRDriveQuery_FilesDelete.query(withFileId: fileID)
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            driveService.executeQuery(deleteQuery) { _, _, error in
                if let error = error {
                    continuation.resume(throwing: CloudDataError.deletionFailed(error))
                } else {
                    continuation.resume()
                }
            }
        }
        
        // Delete file entity from Core Data.
        let context = coreDataManager.context
        let request: NSFetchRequest<RemoteAudioFileEntity> = RemoteAudioFileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", remote.id as CVarArg)
        let results = try context.fetch(request)
        
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
    
    // MARK: - Utility methods
    private func extFromMime(_ mime: String?) -> String {
        guard let mime = mime else { return "" }
        
        if let ut = UTType(mimeType: mime), let ext = ut.preferredFilenameExtension {
            return ext.lowercased()
        }
        
        // Fallback map.
        let map: [String:String] = [
            "audio/mpeg": "mp3",
            "audio/mp3": "mp3",
            "audio/x-m4a": "m4a",
            "audio/mp4": "m4a",
            "audio/aac": "aac",
            "audio/wav": "wav",
            "audio/x-wav": "wav",
            "audio/flac": "flac",
            "audio/ogg": "ogg",
            "audio/alac": "m4a"
        ]
        
        return map[mime, default: ""]
    }
}
