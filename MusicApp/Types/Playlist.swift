//
//  Playlist.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.03.2025.
//

import UIKit

struct Playlist {
    let image: UIImage
    let title: String
    let audios: [AudioFile]?
    
    init(image: UIImage? = nil, title: String? = nil, audios: [AudioFile]? = nil) {
        self.image = image ?? UIImage(image: .icAudioImg)
        
        if let title = title, !title.isEmpty {
            self.title = title
        } else {
            self.title = "Без названия"
        }
        
        self.audios = audios
    }
}
