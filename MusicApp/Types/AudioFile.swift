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
    let url: URL
    let sizeInMB: Double
    let durationInSeconds: Double?
    let artistName: String
    var isDownloading: Bool = false
    let source: AudioSource
}

enum AudioSource: String {
    case local = "local"
    case googleDrive = "google_drive"
}
