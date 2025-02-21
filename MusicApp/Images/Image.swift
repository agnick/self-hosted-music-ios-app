//
//  Image.swift
//  MusicApp
//
//  Created by Никита Агафонов on 14.01.2025.
//

import UIKit

enum Image: String {
    case icLogo = "ic-logo"
    case icAudioDownload = "ic-audio-download"
    case icAudioImg = "ic-audio-img"
    case icAudioImgSvg = "ic-audio-img-svg"
    case icGoogleDrive = "ic-google-drive"
    case icDropbox = "ic-dropbox"
    case icAudioImport = "ic-audio-import"
    case icLocalFiles = "ic-local-files"
    case icMyMusic = "ic-my-music"
    case icPlaylists = "ic-playlists"
    case icSettings = "ic-settings"
    case icPlay = "ic-play"
    case icPause = "ic-pause"
    case icShuffle = "ic-shuffle"
    case icMeatballsMenu = "ic-meatballs-menu"
    case icNextTrack = "ic-next-track"
    case icCheck = "ic-check"
}

extension UIImage {
    convenience init(image: Image) {
        self.init(named: image.rawValue)!
    }
}
