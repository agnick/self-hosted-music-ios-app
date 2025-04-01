import CoreData
import UIKit

final class AudioFilesOverviewScreenWorker: AudioFilesOverviewScreenWorkerProtocol {
    // MARK: - Dependencies
    private let coreDataManager: CoreDataManager
    
    // MARK: - Lifecycle
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Public methods
    func fetchAudioFilesFromStorage(for source: RemoteAudioSource) throws -> [RemoteAudioFile] {
        let context = coreDataManager.context
        
        let request: NSFetchRequest<RemoteAudioFileEntity> = RemoteAudioFileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "sourceRaw == %@", source.rawValue)
        
        let entities = try context.fetch(request)
        
        return entities.map {
            RemoteAudioFile(
                id: $0.id ?? UUID(),
                name: $0.name ?? "Без названия",
                artistName: $0.artistName ?? "",
                trackImg: $0.image.flatMap { UIImage(data: $0) } ?? UIImage(image: .icAudioImgSvg),
                sizeInMB: $0.sizeInMB,
                durationInSeconds: $0.durationInSeconds,
                playbackUrl: $0.playbackUrl ?? "",
                downloadPath: $0.downloadPath ?? "",
                downloadState: RemoteDownloadState(rawValue: $0.downloadStateRaw) ?? .notStarted,
                source: source
            )
        }
    }
}
