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
    
    func toggleRepeat() {
        audioPlayer.toggleRepeat()
    }
    
    func rewind(to time: CMTime) {
        audioPlayer.rewind(to: time)
    }
    
    func isPlaying() -> Bool {
        return audioPlayer.isPlaying()
    }
    
    func getCurrentTrack() -> AudioFile? {
        return audioPlayer.getCurrentTrack()
    }
    
    func getRepeatState() -> Bool {
        return audioPlayer.getRepeatState()
    }
    
    func playNextTrack() {
        audioPlayer.playNextTrack()
    }
    
    func playPrevTrack() {
        audioPlayer.playPrevTrack()
    }
}

final class AudioPlayer: NSObject {
    // MARK: - Variables
    static let shared = AudioPlayer()
    
    private var player: AVPlayer?
    private var currentTrack: AudioFile?
    private var currentPlaylist: [AudioFile] = []
    private var isRepeatEnabled: Bool = false
    private var timeObserverToken: Any?
    
    // MARK: - Lifecycle
    private override init() {
        super.init()
    }
    
    deinit {
        stopObservingTime()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Methods
    @objc private func trackDidFinishPlaying() {
        if isRepeatEnabled {
            player?.seek(to: .zero)
            player?.play()
        } else {
            playNextTrack()
        }
        
        NotificationCenter.default.post(name: .AudioPlayerStateChanged, object: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let status = player?.timeControlStatus {
            if status == .playing || status == .paused {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .AudioPlayerStateChanged, object: nil)
                }
            }
        }
    }
    
    func play(audioFile: AudioFile, playlist: [AudioFile]) {
        currentPlaylist = playlist
        
        guard
            let url = URL(string: audioFile.playbackUrl)
        else {
            return
        }

        let playerItem = AVPlayerItem(url: url)
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
    
    func toggleRepeat() {
        isRepeatEnabled.toggle()
        NotificationCenter.default.post(name: .AudioPlayerRepeatStateChanged, object: isRepeatEnabled)
    }
    
    func rewind(to time: CMTime) {
        player?.seek(to: time)
    }
    
    func isPlaying() -> Bool {
        return player?.timeControlStatus == .playing
    }
    
    func getRepeatState() -> Bool {
        return isRepeatEnabled
    }
    
    func getCurrentTrack() -> AudioFile? {
        return currentTrack
    }
    
    func playNextTrack() {
        guard 
            let currentTrack = currentTrack,
            let currentIndex = currentPlaylist.firstIndex(where: { $0.playbackUrl == currentTrack.playbackUrl })
        else {
            return
        }
        
        let nextIndex = (currentIndex + 1) % currentPlaylist.count
        let nextTrack = currentPlaylist[nextIndex]
        
        play(audioFile: nextTrack, playlist: currentPlaylist)
    }
    
    func playPrevTrack() {
        guard
            let currentTrack = currentTrack,
            let currentIndex = currentPlaylist.firstIndex(where: { $0.playbackUrl == currentTrack.playbackUrl })
        else {
            return
        }
        
        let prevIndex = (currentIndex - 1 + currentPlaylist.count) % currentPlaylist.count
        let prevTrack = currentPlaylist[prevIndex]
        
        play(audioFile: prevTrack, playlist: currentPlaylist)
    }
    
    // MARK: - Private methods
    private func setupPlayer(with playerItem: AVPlayerItem, for audioFile: AudioFile) {
        player = AVPlayer(playerItem: playerItem)
        currentTrack = audioFile
        
        print("Playing \(audioFile.playbackUrl)")
        
        // KVO
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new, .old], context: nil)
        
        NotificationCenter.default.post(name: .AudioPlayerTrackChanged, object: self.currentTrack)
        
        NotificationCenter.default.addObserver(self, selector: #selector(trackDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        player?.play()
        startObservingTime()
    }
    
    private func startObservingTime() {
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            let currentTime = time.seconds
            NotificationCenter.default.post(name: .AudioPlayerTimeChanged, object: currentTime)
        }
    }
    
    private func stopObservingTime() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
}

extension Notification.Name {
    static let AudioPlayerTrackChanged = Notification.Name("AudioPlayerTrackChanged")
    static let AudioPlayerStateChanged = Notification.Name("AudioPlayerStateChanged")
    static let AudioPlayerRepeatStateChanged = Notification.Name("AudioPlayerRepeatStateChanged")
    static let AudioPlayerTimeChanged = Notification.Name("AudioPlayerTimeChanged")
}
