import UIKit
import CoreData

final class NewPlaylistWorker: NewPlaylistWorkerProtocol {
    // MARK: - Dependencies
    private let coreDataManager: CoreDataManager

    // MARK: - Lifecycle
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }

    // MARK: - Public methods
    func savePlaylistToCoreData(mode: PlaylistEditingMode, playlist: Playlist) throws {
        let context = coreDataManager.context

        switch mode {
        case .create:
            let checkRequest: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
            checkRequest.predicate = NSPredicate(format: "title == %@", playlist.title)
            let existing = try context.fetch(checkRequest)

            if !existing.isEmpty {
                throw NewPlaylistError.duplicateName
            }

            let playlistEntity = PlaylistEntity(context: context)
            playlistEntity.id = playlist.id
            playlistEntity.title = playlist.title
            playlistEntity.image = playlist.image.pngData()

            try attachTracks(to: playlistEntity, playlist: playlist, context: context)

        case .edit(let existingPlaylist):
            let duplicateCheck: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
            duplicateCheck.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "title == %@", playlist.title),
                NSPredicate(format: "id != %@", existingPlaylist.id as CVarArg)
            ])
            let duplicates = try context.fetch(duplicateCheck)

            if !duplicates.isEmpty {
                throw NewPlaylistError.duplicateName
            }

            let fetchRequest: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", existingPlaylist.id as CVarArg)

            guard let entity = try context.fetch(fetchRequest).first else {
                throw NewPlaylistError.saveFailed(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Плейлист не найден"]))
            }

            entity.title = playlist.title
            entity.image = playlist.image.pngData()
            entity.downloadedAudios = nil
            entity.remoteAudios = nil

            try attachTracks(to: entity, playlist: playlist, context: context)
        }

        try context.save()
    }

    // MARK: - Private methods
    private func attachTracks(to entity: PlaylistEntity, playlist: Playlist, context: NSManagedObjectContext) throws {
        for downloadedTrack in playlist.downloadedAudios {
            let fetchRequest: NSFetchRequest<DownloadedAudioFileEntity> = DownloadedAudioFileEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", downloadedTrack.id as CVarArg)

            if let result = try? context.fetch(fetchRequest), let existingEntity = result.first {
                entity.addToDownloadedAudios(existingEntity)
            }
        }

        for remoteTrack in playlist.remoteAudios {
            let fetchRequest: NSFetchRequest<RemoteAudioFileEntity> = RemoteAudioFileEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", remoteTrack.id as CVarArg)

            if let result = try? context.fetch(fetchRequest), let existingEntity = result.first {
                entity.addToRemoteAudios(existingEntity)
            }
        }
    }
}
