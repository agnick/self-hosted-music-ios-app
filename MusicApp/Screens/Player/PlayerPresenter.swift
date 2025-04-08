//
//  PlayerPresenter.swift
//  MusicApp
//
//  Created by Никита Агафонов on 19.02.2025.
//

import UIKit

final class PlayerPresenter: PlayerPresentationLogic {
    weak var view: PlayerViewController?
    
    func presentStart(_ request: PlayerModel.Start.Response) {
        DispatchQueue.main.async {
            self.view?.displayStart(PlayerModel.Start.ViewModel(trackName: request.currentTrack.name, artistName: request.currentTrack.artistName, trackDuration: request.currentTrack.durationInSeconds, currentTime: request.currentTime))
        }
    }
    
    func presentPlayPauseState(_ response: PlayerModel.PlayPause.Response) {
        DispatchQueue.main.async {
            let image: UIImage = response.playPauseState ? UIImage(image: .icPause) : UIImage(image: .icPlay)
            self.view?.displayPlayPauseState(PlayerModel.PlayPause.ViewModel(playPauseImage: image))
        }
    }
    
    func presentRepeatState(_ response: PlayerModel.Repeat.Response) {
        DispatchQueue.main.async {
            let imageColor: UIColor = response.isRepeatEnabled ? UIColor(color: .primary) : .black
            self.view?.displatRepeatState(PlayerModel.Repeat.ViewModel(repeatImageColor: imageColor))
        }
    }
    
    func routeTo() {
        view?.navigationController?.pushViewController(UIViewController(), animated: true)
    }
}
