//
//  AudioFile.swift
//  MusicApp
//
//  Created by Никита Агафонов on 08.01.2025.
//

import Foundation

// Structure for storing audio file details.
struct AudioFile {
    let name: String
    let artistName: String
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
