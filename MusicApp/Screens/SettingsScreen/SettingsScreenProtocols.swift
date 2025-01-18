//
//  SettingsScreenProtocols.swift
//  MusicApp
//
//  Created by Никита Агафонов on 12.01.2025.
//

protocol SettingsScreenBusinessLogic {
    func loadStart(_ request: SettingsScreenModel.Start.Request)
    func logoutFromService(_ request: SettingsScreenModel.Logout.Request)
}

protocol SettingsScreenPresentationLogic {
    func presentStart(_ response: SettingsScreenModel.Start.Response)
    
    func routeTo()
}
