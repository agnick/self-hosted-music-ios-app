//
//  PlayerProtocols.swift
//  MusicApp
//
//  Created by Никита Агафонов on 19.02.2025.
//

protocol PlayerBusinessLogic {
    func loadStart()
    func repeatTrack()
    func playPrevTrack()
    func playPause()
    func playNextTrack()
    func rewindTrack(_ request: PlayerModel.Rewind.Request)
    
    func loadPlayPauseState()
    func loadRepeatState()
}

protocol PlayerPresentationLogic {
    func presentStart(_ response: PlayerModel.Start.Response)
    func presentPlayPauseState(_ response: PlayerModel.PlayPause.Response)
    func presentRepeatState(_ response: PlayerModel.Repeat.Response)
    
    func routeTo()
}
