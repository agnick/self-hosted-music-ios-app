//
//  NewPlaylist.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.03.2025.
//

import UIKit

enum NewPlaylistModel {
    enum CellData {
        struct Request {
            let index: Int
        }
        
        struct Response {
            let index: Int
            let audioFile: AudioFile
        }
        
        struct ViewModel {
            let index: Int
            let name: String
            let artistName: String
            let durationInSeconds: Double?
        }
    }
    
    enum SelectedTracks {
        struct Request {
            let audioFiles: [AudioFile]
        }
    }
    
    enum PlaylistImage {
        struct Request {
            let imageData: Any?
        }
        
        struct Response {
            let imageData: Any?
        }
        
        struct ViewModel {
            let image: UIImage
        }
    }
    
    enum RemoveTrack {
        struct Request {
            let index: Int
        }
    }
    
    enum PlaylistName {
        struct Request {
            let playlistName: String
        }
    }
    
    enum Error {
        struct Response {
            let error: Swift.Error
        }
        
        struct ViewModel {
            let errorDescription: String
        }
    }
}
