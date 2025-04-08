//
//  PlaylistsInteractor.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.03.2025.
//

import CoreData
import UIKit

final class PlaylistsInteractor: PlaylistsBusinessLogic, PlaylistsDataStore {
    // MARK: - Variables
    private let presenter: PlaylistsPresentationLogic
    private let coreDataManager: CoreDataManager
    private let userDefaultsManager: UserDefaultsManager
    
    var playlists: [Playlist] = []
    private var fetchedPlaylists: [Playlist] = []
    private var searchQuery: String = ""
    
    // MARK: - Lifecycle
    init (presenter: PlaylistsPresentationLogic, coreDataManager: CoreDataManager, userDefaultsManager: UserDefaultsManager) {
        self.presenter = presenter
        self.coreDataManager = coreDataManager
        self.userDefaultsManager = userDefaultsManager
    }
    
    // MARK: - Public methods
    func createPlaylist() {
        presenter.routeTo(vc: NewPlaylistAssembly.build(coreDataManager: coreDataManager))
    }
    
    func fetchAllPlaylists() {
        let context = coreDataManager.context
        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        request.relationshipKeyPathsForPrefetching = ["audioFiles"]
        
        do {
            let entities = try context.fetch(request)
            
            fetchedPlaylists = entities.map { entity in
                let image: UIImage = entity.image.flatMap(UIImage.init(data:)) ?? UIImage(image: .icAudioImg)
                
                let audioFiles = (entity.audioFiles as? Set<AudioFileEntity>)?.map { audio in
                    AudioFile(
                        name: audio.name ?? "", artistName: audio.artistName ?? "", sizeInMB: audio.sizeInMB, durationInSeconds: audio.durationInSeconds, downloadPath: audio.downloadPath ?? "", playbackUrl: audio.playbackUrl ?? "", downloadState: DownloadState(rawValue: audio.downloadStateRaw) ?? .notStarted, source: AudioSource(rawValue: audio.sourceRaw) ?? .local
                    )
                }
                
                return Playlist(image: image, title: entity.title, audios: audioFiles)
            }
            
            applySortingAndFiltering()
        } catch {
            print("Ошибка при получении плейлистов")
        }
    }
    
    func loadSortOptions() {
        presenter.presentSortOptions()
    }
    
    func sortPlaylists(_ request: PlaylistsModel.Sort.Request) {
        userDefaultsManager.saveSortPreference(request.sortType, for: UserDefaultsKeys.sortPlaylistsKey)
        applySortingAndFiltering()
    }
    
    func searchPlaylists(_ request: PlaylistsModel.Search.Request) {
        searchQuery = request.query
        applySortingAndFiltering()
    }
    
    // MARK: - Private methods
    private func applySortingAndFiltering() {
        let sortType = userDefaultsManager.loadSortPreference(for: UserDefaultsKeys.sortPlaylistsKey)
        
        playlists = fetchedPlaylists
        
        if !searchQuery.isEmpty {
            playlists = playlists.filter {
                $0.title.lowercased().contains(searchQuery.lowercased())
            }
        }

        switch sortType {
        case .titleAscending:
            playlists.sort { $0.title.lowercased() < $1.title.lowercased() }
        case .titleDescending:
            playlists.sort { $0.title.lowercased() > $1.title.lowercased() }
        default:
            break
        }

        presenter.presentAllPlaylists()
    }
}
