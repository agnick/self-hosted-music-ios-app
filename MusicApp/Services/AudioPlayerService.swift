//
//  AudioPlayerManager.swift
//  MusicApp
//
//  Created by Никита Агафонов on 01.02.2025.
//

import AVFoundation
import UIKit

struct AudioPlayerService {
    private let audioPlayer = AudioPlayer.shared
    
    func play(audioFile: AudioFile, playlist: [AudioFile]) {
        audioPlayer.play(audioFile: audioFile, playlist: playlist)
    }
    
    func togglePlayPause() {
        audioPlayer.togglePlayPause()
    }
    
    func isPlaying() -> Bool {
        return audioPlayer.isPlaying()
    }
    
    func getCurrentTrack() -> AudioFile? {
        return audioPlayer.getCurrentTrack()
    }
    
    func playNextTrack() {
        audioPlayer.playNextTrack()
    }
}

final class AudioPlayer: NSObject {
    static let shared = AudioPlayer()
    
    private var player: AVPlayer?
    private var currentTrack: AudioFile?
    private var currentPlaylist: [AudioFile] = []
    
    private override init() {
        super.init()
    }
    
    @objc private func trackDidFinishPlaying() {
        playNextTrack()
        NotificationCenter.default.post(name: .AudioPlayerStateChanged, object: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .AudioPlayerStateChanged, object: nil)
        }
    }
    
    func play(audioFile: AudioFile, playlist: [AudioFile]) {
        currentPlaylist = playlist

        let playerItem = AVPlayerItem(url: audioFile.url)
        setupPlayer(with: playerItem, for: audioFile)
    }
    
    func togglePlayPause() {
        guard let player = player else { return }
        
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
        }
    }
    
    func isPlaying() -> Bool {
        return player?.timeControlStatus == .playing
    }
    
    func getCurrentTrack() -> AudioFile? {
        return currentTrack
    }
    
    func playNextTrack() {
        guard 
            let currentTrack = currentTrack,
            let currentIndex = currentPlaylist.firstIndex(where: { $0.url == currentTrack.url })
        else { return }
        
        let nextIndex = (currentIndex + 1) % currentPlaylist.count
        let nextTrack = currentPlaylist[nextIndex]
        
        play(audioFile: nextTrack, playlist: currentPlaylist)
    }
    
    // MARK: - Private methods
    private func setupPlayer(with playerItem: AVPlayerItem, for audioFile: AudioFile) {
        player = AVPlayer(playerItem: playerItem)
        currentTrack = audioFile
        
        print("Playing \(audioFile.url)")
        
        // KVO
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new, .old], context: nil)
        
        NotificationCenter.default.post(name: .AudioPlayerTrackChanged, object: self.currentTrack)
        
        NotificationCenter.default.addObserver(self, selector: #selector(trackDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        player?.play()
    }
}

extension Notification.Name {
    static let AudioPlayerTrackChanged = Notification.Name("AudioPlayerTrackChanged")
    static let AudioPlayerStateChanged = Notification.Name("AudioPlayerStateChanged")
}
