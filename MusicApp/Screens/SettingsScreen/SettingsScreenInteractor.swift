//
//  SettingsScreenInteractor.swift
//  MusicApp
//
//  Created by Никита Агафонов on 12.01.2025.
//

final class SettingsScreenInteractor: SettingsScreenBusinessLogic {
    private let presenter: SettingsScreenPresentationLogic
    private let cloudAuthService: CloudAuthService
    
    init (presenter: SettingsScreenPresentationLogic, cloudAuthService: CloudAuthService) {
        self.presenter = presenter
        self.cloudAuthService = cloudAuthService
    }
    
    func loadStart(_ request: SettingsScreenModel.Start.Request) {
        let cloudService = cloudAuthService.getAuthorizedService()
        presenter.presentStart(SettingsScreenModel.Start.Response(cloudService: cloudService))
    }
    
    func logoutFromService(_ request: SettingsScreenModel.Logout.Request) {
        Task {
            guard let cloudService = cloudAuthService.getAuthorizedService() else {
                print("Not logged")
                return
            }
            
            do {
                try await cloudAuthService.logout(from: cloudService)
                print("Logged out from \(cloudService.displayName)")
            } catch {
                print("Logout error: \(error.localizedDescription)")
            }
        }
    }
}
