//
//  AudioFile.swift
//  MusicApp
//
//  Created by Никита Агафонов on 08.01.2025.
//

import Foundation
import UIKit

// Structure for storing audio file details.
struct AudioFile {
    let name: String
    let artistName: String
    let trackImg: UIImage = UIImage(image: .icAudioImgSvg)
    let sizeInMB: Double
    let durationInSeconds: Double?
    let downloadPath: String
    let playbackUrl: String
    var downloadState: DownloadState = .notStarted
    let source: AudioSource
}

enum AudioSource: String {
    case local = "local"
    case googleDrive = "google_drive"
    case dropbox = "dropbox"
}

extension AudioFile: Equatable {
    static func == (lhs: AudioFile, rhs: AudioFile) -> Bool {
        return lhs.playbackUrl == rhs.playbackUrl
    }
}
