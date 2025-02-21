//
//  PlayerProtocols.swift
//  MusicApp
//
//  Created by Никита Агафонов on 19.02.2025.
//

protocol PlayerBusinessLogic {
    func loadStart(_ request: PlayerModel.Start.Request)
}

protocol PlayerPresentationLogic {
    func presentStart(_ response: PlayerModel.Start.Response)
    
    func routeTo()
}
