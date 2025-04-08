//
//  NewPlaylistWorker.swift
//  MusicApp
//
//  Created by Никита Агафонов on 10.03.2025.
//

import UIKit

final class NewPlaylistWorker: NewPlaylistWorkerProtocol {
    private let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    func savePlaylistToCoreData(playlist: Playlist) {
        let context = coreDataManager.context
        
        let playlistEntity = PlaylistEntity(context: context)
        playlistEntity.title = playlist.title
        playlistEntity.image = playlist.image.pngData()
        
        if let audioFiles = playlist.audios {
            for audioFile in audioFiles {
                let audioFileEntity = AudioFileEntity(context: context)
                audioFileEntity.name = audioFile.name
                audioFileEntity.artistName = audioFile.artistName
                audioFileEntity.sizeInMB = audioFile.sizeInMB
                audioFileEntity.durationInSeconds = audioFile.durationInSeconds ?? 0
                audioFileEntity.downloadPath = audioFile.downloadPath
                audioFileEntity.playbackUrl = audioFile.playbackUrl
                audioFileEntity.downloadStateRaw = audioFile.downloadState.rawValue
                audioFileEntity.sourceRaw = audioFile.source.rawValue
                
                audioFileEntity.playlist = playlistEntity
            }
        }
        
        coreDataManager.saveContext()
    }
}
