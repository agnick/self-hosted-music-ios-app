import AVFoundation
import UIKit
import MediaPlayer

struct AudioPlayerService {
    // MARK: - Dependencies
    private let audioPlayer = AudioPlayer.shared
    
    // MARK: - Public proxy methods
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
    
    func removeTrackFromPlaylist(_ audioFile: AudioFile) {
        audioPlayer.removeTrackFromPlaylist(audioFile)
    }
    
    func updateCurrentTrack(with updatedTrack: AudioFile) {
        audioPlayer.updateCurrentTrack(with: updatedTrack)
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
    
    func getCurrentTime() -> Double {
        return audioPlayer.getCurrentTime()
    }
}

final class AudioPlayer: NSObject {
    // MARK: - Singlton
    static let shared = AudioPlayer()
    
    // MARK: - States
    private var player: AVPlayer?
    private var currentTrack: AudioFile?
    private var currentPlaylist: [AudioFile] = []
    private var isRepeatEnabled: Bool = false
    private var timeObserverToken: Any?
    private var pauseTimer: Timer?
    
    // MARK: - Lifecycle
    private override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    deinit {
        stopObservingTime()
        
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
                NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    @objc private func trackDidFinishPlaying() {
        if isRepeatEnabled {
            player?.seek(to: .zero)
            player?.play()
        } else {
            playNextTrack()
        }
        
        NotificationCenter.default.post(name: .AudioPlayerStateChanged, object: nil)
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else {
            return
        }
            
        switch type {
        case .began:
            player?.pause()
        case .ended:
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    player?.play()
                }
            }
        default:
            break
        }
    }
    
    // MARK: - Public methods
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
    
    func updateCurrentTrack(with updatedTrack: AudioFile) {
        currentTrack = updatedTrack
        NotificationCenter.default.post(name: .AudioPlayerTrackChanged, object: updatedTrack)
    }
    
    func removeTrackFromPlaylist(_ audioFile: AudioFile) {
        let wasCurrent = currentTrack?.id == audioFile.id
        
        currentPlaylist.removeAll { $0.id == audioFile.id }
        
        guard !currentPlaylist.isEmpty else {
            stopPlaybackCompletely()
            return
        }
        
        guard wasCurrent else { return }
        
        guard let nextTrack = currentPlaylist.first else {
            return
        }
        
        play(audioFile: nextTrack, playlist: currentPlaylist)
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
        updateNowPlayingInfo()
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
        updateNowPlayingInfo()
    }
    
    func getCurrentTime() -> Double {
        return player?.currentTime().seconds ?? 0
    }
    
    // MARK: - Private methods
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
            
        commandCenter.playCommand.addTarget { [weak self] event in
            self?.player?.play()
            return .success
        }
            
        commandCenter.pauseCommand.addTarget { [weak self] event in
            self?.player?.pause()
            return .success
        }
            
        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            self?.playNextTrack()
            return .success
        }
            
        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            self?.playPrevTrack()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            
            let time = CMTime(seconds: positionEvent.positionTime, preferredTimescale: 1)
            
            self?.player?.seek(to: time)
            
            self?.updateNowPlayingInfo()
            return .success
        }
    }
    
    private func setupPlayer(with playerItem: AVPlayerItem, for audioFile: AudioFile) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error in setting up AVAudioSession: \(error)")
        }
        
        print("HERE")
        
        stopObservingTime()
        
        player = AVPlayer(playerItem: playerItem)
        currentTrack = audioFile
        
        print("Playing \(audioFile.playbackUrl)")
        
        // KVO
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new, .old], context: nil)
        
        NotificationCenter.default.post(name: .AudioPlayerTrackChanged, object: self.currentTrack)
        
        NotificationCenter.default.addObserver(self, selector: #selector(trackDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        player?.play()
        setupRemoteCommandCenter()
        updateNowPlayingInfo()
        startObservingTime()
    }
    
    private func updateNowPlayingInfo() {
        guard let currentTrack = currentTrack else { return }
            
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = currentTrack.name
        nowPlayingInfo[MPMediaItemPropertyArtist] = currentTrack.artistName
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = currentTrack.durationInSeconds
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds ?? 0
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate ?? 0
        
        let artworkImage = currentTrack.trackImg
        let artwork = MPMediaItemArtwork(boundsSize: artworkImage.size) { _ in
            return artworkImage
        }
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func startObservingTime() {
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            let currentTime = time.seconds
            NotificationCenter.default.post(name: .AudioPlayerTimeChanged, object: currentTime)
            self?.updateNowPlayingInfo()
        }
    }
    
    private func stopObservingTime() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    private func stopPlaybackCompletely() {
        player?.pause()
        player = nil
        currentTrack = nil
        NotificationCenter.default.post(name: .AudioPlayerStateChanged, object: nil)
        NotificationCenter.default.post(name: .AudioPlayerTrackChanged,  object: nil)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
}

extension Notification.Name {
    static let AudioPlayerTrackChanged = Notification.Name("AudioPlayerTrackChanged")
    static let AudioPlayerStateChanged = Notification.Name("AudioPlayerStateChanged")
    static let AudioPlayerRepeatStateChanged = Notification.Name("AudioPlayerRepeatStateChanged")
    static let AudioPlayerTimeChanged = Notification.Name("AudioPlayerTimeChanged")
}
