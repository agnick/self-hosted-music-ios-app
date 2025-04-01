import CoreData
import UIKit

final class PlaylistsWorker: PlaylistsWorkerProtocol {
    // MARK: - Dependencies
    private let coreDataManager: CoreDataManager
    
    // MARK: - Lifecycle
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Public methods
    func fetchAllPlaylists() throws -> [Playlist] {
        let context = coreDataManager.context
        
        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        request.relationshipKeyPathsForPrefetching = ["downloadedAudios", "remoteAudios"]
        
        let entities = try context.fetch(request)
        
        return entities.map { entity in
            let cover: UIImage = entity.image.flatMap(UIImage.init(data:)) ?? UIImage(image: .icAudioImgSvg)
            
            let downloaded: [DownloadedAudioFile] = (entity.downloadedAudios as? Set<DownloadedAudioFileEntity>)?.compactMap {
                DownloadedAudioFile(from: $0)
            } ?? []
            
            let remote: [RemoteAudioFile] = (entity.remoteAudios as? Set<RemoteAudioFileEntity>)?.compactMap {
                RemoteAudioFile(from: $0)
            } ?? []
            
            return Playlist(
                id: entity.id ?? UUID(),
                image: cover,
                title: entity.title,
                downloadedAudios: downloaded,
                remoteAudios: remote
            )
        }
    }

    
    func deletePlaylist(_ playlistId: UUID) throws {
        let context = coreDataManager.context
        
        let fetchRequest: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", playlistId as CVarArg)
        
        if let playlistEntity = try context.fetch(fetchRequest).first {
            context.delete(playlistEntity)
            try coreDataManager.saveContext()
        }
    }
}
