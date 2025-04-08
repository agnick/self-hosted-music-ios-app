//
//  PlayerModels.swift
//  MusicApp
//
//  Created by Никита Агафонов on 19.02.2025.
//

import UIKit
import CoreMedia

enum PlayerModel {
    enum Start {
        struct Response {
            let currentTrack: AudioFile
            let currentTime: Double
        }
        
        struct ViewModel {
            let trackName: String
            let artistName: String
            let trackDuration: Double?
            let currentTime: Double
        }
    }
    
    enum PlayPause {
        struct Response {
            let playPauseState: Bool
        }
        
        struct ViewModel {
            let playPauseImage: UIImage
        }
    }
    
    enum Repeat {
        struct Response {
            let isRepeatEnabled: Bool
        }
        
        struct ViewModel {
            let repeatImageColor: UIColor
        }
    }
    
    enum Rewind {
        struct Request {
            let sliderValue: Float
        }
    }
}
