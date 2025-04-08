//
//  PlayerInteractor.swift
//  MusicApp
//
//  Created by Никита Агафонов on 19.02.2025.
//

import CoreMedia

final class PlayerInteractor: PlayerBusinessLogic {
    // MARK: - Variables
    private let presenter: PlayerPresentationLogic
    private let audioPlayerService: AudioPlayerService
    
    // MARK: - Lifecycle
    init (presenter: PlayerPresentationLogic, audioPlayerService: AudioPlayerService) {
        self.presenter = presenter
        self.audioPlayerService = audioPlayerService
    }
    
    // MARK: - Public methods
    func loadStart() {
        if let currentTrack = audioPlayerService.getCurrentTrack() {
            let currentTime = audioPlayerService.getCurrentTime()
            
            presenter.presentStart(PlayerModel.Start.Response(currentTrack: currentTrack, currentTime: currentTime))
            loadPlayPauseState()
            loadRepeatState()
        }
    }
    
    func repeatTrack() {
        audioPlayerService.toggleRepeat()
    }
    
    func playPrevTrack() {
        audioPlayerService.playPrevTrack()
    }
    
    func playPause() {
        audioPlayerService.togglePlayPause()
    }
    
    func playNextTrack() {
        audioPlayerService.playNextTrack()
    }
    
    func rewindTrack(_ request: PlayerModel.Rewind.Request) {
        let time = CMTime(seconds: Double(request.sliderValue), preferredTimescale: 1)
        audioPlayerService.rewind(to: time)
    }
    
    func loadPlayPauseState() {
        let isPlaying = audioPlayerService.isPlaying()
        
        presenter.presentPlayPauseState(PlayerModel.PlayPause.Response(playPauseState: isPlaying))
    }
    
    func loadRepeatState() {
        let isRepeatEnabled = audioPlayerService.getRepeatState()
        
        presenter.presentRepeatState(PlayerModel.Repeat.Response(isRepeatEnabled: isRepeatEnabled))
    }
}
