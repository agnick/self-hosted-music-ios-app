import Foundation
import CoreData

final class PlaylistWorker: PlaylistWorkerProtocol {    
    // MARK: - Dependencies
    private let coreDataManager: CoreDataManager
    private let userDefaultsManager: UserDefaultsManager
    
    // MARK: - Lifecycle
    init(coreDataManager: CoreDataManager, userDefaultsManager: UserDefaultsManager) {
        self.coreDataManager = coreDataManager
        self.userDefaultsManager = userDefaultsManager
    }
    
    // MARK: - Public methods
    func loadSortPreference() -> SortType {
        return userDefaultsManager.loadSortPreference(for: UserDefaultsKeys.sortAudiosKey)
    }
    
    func getAllPlaylists(currentPlaylist: Playlist) -> [PlaylistEntity] {
        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id != %@", currentPlaylist.id as CVarArg)
        
        let context = coreDataManager.context
        
        do {
            let playlists = try context.fetch(request)
            return playlists
        } catch {
            return []
        }
    }
    
    func saveToPlaylist(_ audioFile: any AudioFile, to playlist: PlaylistEntity) throws {
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
        
        do {
            try coreDataManager.saveContext()
        } catch {
            throw PlaylisError.saveFailed(error)
        }
    }
    
    func deleteDownloadedAudioFile(_ audioFile: DownloadedAudioFile) throws {
        let context = coreDataManager.context

        guard let fileURL = URL(string: audioFile.playbackUrl), fileURL.isFileURL else {
            throw PlaylisError.invalidResponse
        }

        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }

        let request: NSFetchRequest<DownloadedAudioFileEntity> = DownloadedAudioFileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", audioFile.id as CVarArg)
        
        let results = try context.fetch(request)
        guard let entity = results.first else {
            throw PlaylisError.entityNotFound
        }

        context.delete(entity)

        do {
            try coreDataManager.saveContext()
        } catch {
            throw PlaylisError.saveFailed(error)
        }
    }
    
    func deleteFromPlaylist(_ audioFile: AudioFile, from playlist: Playlist) throws {
        let context = coreDataManager.context

        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", playlist.id as CVarArg)
        
        guard let playlistEntity = try context.fetch(request).first else {
            throw PlaylisError.entityNotFound
        }

        if let remoteFile = audioFile as? RemoteAudioFile {
            let fetch: NSFetchRequest<RemoteAudioFileEntity> = RemoteAudioFileEntity.fetchRequest()
            fetch.predicate = NSPredicate(format: "id == %@", remoteFile.id as CVarArg)
            
            if let entity = try context.fetch(fetch).first {
                playlistEntity.removeFromRemoteAudios(entity)
            }
        } else if let downloadedFile = audioFile as? DownloadedAudioFile {
            let fetch: NSFetchRequest<DownloadedAudioFileEntity> = DownloadedAudioFileEntity.fetchRequest()
            fetch.predicate = NSPredicate(format: "id == %@", downloadedFile.id as CVarArg)
            
            if let entity = try context.fetch(fetch).first {
                playlistEntity.removeFromDownloadedAudios(entity)
            }
        }
        
        do {
            try coreDataManager.saveContext()
        } catch {
            throw PlaylisError.saveFailed(error)
        }
    }
    
    func fetchPlaylist(by id: UUID) throws -> Playlist {
        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let entity = try coreDataManager.context.fetch(request).first else {
            throw PlaylisError.entityNotFound
        }

        return Playlist(from: entity)
    }
}
