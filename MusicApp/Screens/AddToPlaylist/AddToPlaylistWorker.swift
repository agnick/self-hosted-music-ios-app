import CoreData

final class AddToPlaylistWorker: AddToPlaylistWorkerProtocol {
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
    
    func fetchDownloaded() -> [DownloadedAudioFile] {
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
    
    func fetchRemote(from source: RemoteAudioSource) -> [RemoteAudioFile] {
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
}
