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
        guard let cloudService = cloudAuthService.getAuthorizedService() else {
            print("Not logged")
            return
        }
        
        cloudAuthService.logout(from: cloudService) { result in
            switch result {
            case .success():
                print("Logged out from \(cloudService.displayName)")
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
        
    }
}
