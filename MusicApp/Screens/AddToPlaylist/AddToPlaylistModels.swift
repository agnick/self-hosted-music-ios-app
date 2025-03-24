//
//  AddToPlaylistModels.swift
//  MusicApp
//
//  Created by Никита Агафонов on 06.03.2025.
//

enum AddToPlaylistModel {
    enum LocalAudioFiles {
        struct Response {
            let audioFiles: [AudioFile]
            let selectedAudioFiles: Set<String>
        }
        
        struct ViewModel {
            let filesCount: String
            let selectedFilesCount: String
        }
    }
    
    enum PreLoading {
        struct ViewModel {
            let buttonsState: Bool
        }
    }
    
    enum CellData {
        struct Request {
            let index: Int
        }
        
        struct Response {
            let index: Int
            let isEditingMode: Bool
            let isSelected: Bool
            let audioFile: AudioFile
        }
        
        struct ViewModel {
            let index: Int
            let isEditingMode: Bool
            let isSelected: Bool
            let name: String
            let artistName: String
            let durationInSeconds: Double?
        }
    }
    
    enum TrackSelection {
        struct Request {
            let index: Int
        }
        
        struct Response {
            let index: Int
            let selectedAudioFiles: Set<String>
        }
        
        struct ViewModel {
            let index: Int
            let isSelected: Bool
            let selectedAudioFilesCount: String
        }
    }
    
    enum PickTracks {
        struct Response {
            let state: Bool
            let selectedAudioFiles: Set<String>
        }
        
        struct ViewModel {
            let buttonTitle: String
            let state: Bool
            let selectedAudioFilesCount: String
        }
    }
    
    enum Search {
        struct Request {
            let query: String
        }
    }
    
    enum SendTracks {
        struct Response {
            let selectedAudioFiles: [AudioFile]
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
