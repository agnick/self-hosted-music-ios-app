//
//  PlayerInteractor.swift
//  MusicApp
//
//  Created by Никита Агафонов on 19.02.2025.
//

final class PlayerInteractor: PlayerBusinessLogic {
    private let presenter: PlayerPresentationLogic
    
    init (presenter: PlayerPresentationLogic) {
        self.presenter = presenter
    }
    
    func loadStart(_ request: PlayerModel.Start.Request) {
        presenter.presentStart(PlayerModel.Start.Response())
    }
}
