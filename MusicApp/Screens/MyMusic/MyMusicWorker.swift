import CoreData
import UIKit

final class MyMusicWorker : MyMusicWorkerProtocol {
    // MARK: - Dependencies
    private let coreDataManager: CoreDataManager
    
    // MARK: - Lifecycle
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Public Methods
    func saveToPlaylist(_ audioFile: AudioFile, to playlist: PlaylistEntity) throws {
        let context = coreDataManager.context
        
        if let remoteFile = audioFile as? RemoteAudioFile {
            let request: NSFetchRequest<RemoteAudioFileEntity> = RemoteAudioFileEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", remoteFile.id as CVarArg)
            let existing = try context.fetch(request).first

            let entity: RemoteAudioFileEntity
            if let existing = existing {
                entity = existing
            } else {
                entity = RemoteAudioFileEntity(context: context)
                entity.id = remoteFile.id
                entity.name = remoteFile.name
                entity.artistName = remoteFile.artistName
                entity.image = remoteFile.trackImg.pngData()
                entity.sizeInMB = remoteFile.sizeInMB
                entity.durationInSeconds = remoteFile.durationInSeconds
                entity.playbackUrl = remoteFile.playbackUrl
                entity.downloadPath = remoteFile.downloadPath
                entity.downloadStateRaw = remoteFile.downloadState.rawValue
                entity.sourceRaw = remoteFile.source.rawValue
            }

            entity.playlist = playlist
            playlist.addToRemoteAudios(entity)
        } else if let downloadedFile = audioFile as? DownloadedAudioFile {
            let request: NSFetchRequest<DownloadedAudioFileEntity> = DownloadedAudioFileEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", downloadedFile.id as CVarArg)
            let existing = try context.fetch(request).first

            let entity: DownloadedAudioFileEntity
            if let existing = existing {
                entity = existing
            } else {
                entity = DownloadedAudioFileEntity(context: context)
                entity.id = downloadedFile.id
                entity.name = downloadedFile.name
                entity.artistName = downloadedFile.artistName
                entity.image = downloadedFile.trackImg.pngData()
                entity.sizeInMB = downloadedFile.sizeInMB
                entity.durationInSeconds = downloadedFile.durationInSeconds
                entity.playbackUrl = downloadedFile.playbackUrl
                entity.downloadPath = downloadedFile.playbackUrl
            }

            entity.playlist = playlist
            playlist.addToDownloadedAudios(entity)
        }
        
        try coreDataManager.saveContext()
    }

    func getAllPlaylists() -> [PlaylistEntity] {
        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        let context = coreDataManager.context
        
        do {
            let playlists = try context.fetch(request)
            return playlists
        } catch {
            return []
        }
    }
    
    func fetchRemoteAudioFiles(from source: RemoteAudioSource) -> [RemoteAudioFile] {
        let context = coreDataManager.context
        let request: NSFetchRequest<RemoteAudioFileEntity> = RemoteAudioFileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "sourceRaw == %@", source.rawValue)
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                guard entity.id != nil else { return nil }
                
                return RemoteAudioFile(from: entity)
            }
        } catch {
            return []
        }
    }
    
    func fetchDownloadedAudioFiles() -> [DownloadedAudioFile] {
        let context = coreDataManager.context
        let request: NSFetchRequest<DownloadedAudioFileEntity> = DownloadedAudioFileEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                guard entity.id != nil else { return nil }
                
                return DownloadedAudioFile(from: entity)
            }
        } catch {
            return []
        }
    }
    
    func deleteDownloadedAudioFile(_ audioFile: DownloadedAudioFile) throws {
        let context = coreDataManager.context

        guard let fileURL = URL(string: audioFile.playbackUrl), fileURL.isFileURL else {
            throw CloudDataError.invalidResponse
        }

        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }

        let request: NSFetchRequest<DownloadedAudioFileEntity> = DownloadedAudioFileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", audioFile.id as CVarArg)
        
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
}
