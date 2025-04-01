import UIKit
import CoreData

final class EditAudioWorker: EditAudioWorkerProtocol {
    // MARK: - Dependencies
    private let coreDataManager: CoreDataManager
    
    // MARK: - Lifecycle
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Public methods
    func updateAudioFileInCoreData(audioFile: AudioFile) throws {
        let context = coreDataManager.context

        if let downloaded = audioFile as? DownloadedAudioFile {
            let request: NSFetchRequest<DownloadedAudioFileEntity> = DownloadedAudioFileEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", downloaded.id as CVarArg)

            if let entity = try? context.fetch(request).first {
                entity.name = downloaded.name
                entity.artistName = downloaded.artistName
                entity.image = downloaded.trackImg.pngData()
            }
        } else if let remote = audioFile as? RemoteAudioFile {
            let request: NSFetchRequest<RemoteAudioFileEntity> = RemoteAudioFileEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", remote.id as CVarArg)

            if let entity = try? context.fetch(request).first {
                entity.name = remote.name
                entity.artistName = remote.artistName
                entity.image = remote.trackImg.pngData()
            }
        }

        do {
            try coreDataManager.saveContext()
        } catch {
            throw EditAudioError.saveFailed(error)
        }
    }
}
