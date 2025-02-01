//
//  AudioPlayerManager.swift
//  MusicApp
//
//  Created by Никита Агафонов on 01.02.2025.
//

import AVFoundation
import UIKit

struct AudioPlayerService {
    private let audioPlayerManager = AudioPlayerManager.shared
    
    func play(audioFile: AudioFile) {
        audioPlayerManager.play(audioFile: audioFile)
    }
    
    func togglePlayPause() {
        audioPlayerManager.togglePlayPause()
    }
    
    func isPlaying() -> Bool {
        return audioPlayerManager.isPlaying()
    }
}

final class AudioPlayerManager {
    static let shared = AudioPlayerManager()
    
    private var player: AVPlayer?
    private var currentTrack: AudioFile?
    
    private init() {}
    
    @objc private func trackDidFinishPlaying() {
        NotificationCenter.default.post(name: .AudioPlayerStateChanged, object: nil)
    }
    
    func play(audioFile: AudioFile) {
        let playerItem = AVPlayerItem(url: audioFile.url)
        
        player = AVPlayer(playerItem: playerItem)
        
        currentTrack = audioFile;
        
        NotificationCenter.default.post(name: .AudioPlayerTrackChanged, object: currentTrack)
        
        NotificationCenter.default.addObserver(self, selector: #selector(trackDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        player?.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(name: .AudioPlayerStateChanged, object: nil)
        }
    }
    
    func togglePlayPause() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            } else {
                player.play()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(name: .AudioPlayerStateChanged, object: nil)
        }
    }
    
    func isPlaying() -> Bool {
        return player?.timeControlStatus == .playing
    }
}

extension Notification.Name {
    static let AudioPlayerTrackChanged = Notification.Name("AudioPlayerTrackChanged")
    static let AudioPlayerStateChanged = Notification.Name("AudioPlayerStateChanged")
}
