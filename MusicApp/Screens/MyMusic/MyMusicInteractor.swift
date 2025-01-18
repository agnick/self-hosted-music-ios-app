//
//  MyMusicInteractor.swift
//  MusicApp
//
//  Created by Никита Агафонов on 17.01.2025.
//

final class MyMusicInteractor: MyMusicBusinessLogic {
    private let presenter: MyMusicPresentationLogic
    private let cloudAuthService: CloudAuthService
    private let cloudAudioService: CloudAudioService
    
    init (presenter: MyMusicPresentationLogic, cloudAuthService: CloudAuthService, cloudAudioService: CloudAudioService) {
        self.presenter = presenter
        self.cloudAuthService = cloudAuthService
        self.cloudAudioService = cloudAudioService
    }
    
    func loadStart(_ request: MyMusicModel.Start.Request) {
        let cloudService = cloudAuthService.getAuthorizedService()
        
        presenter.presentStart(MyMusicModel.Start.Response(cloudService: cloudService))
    }
    
    func fetchCloudAudioFiles(_ request: MyMusicModel.FetchedFiles.Request) {
        guard let service = cloudAuthService.getAuthorizedService() else {
            return
        }
        
        cloudAudioService.fetchAudioFiles(for: service, forceRefresh: true) { [weak self] result in
            switch result {
            case .success:
                let audioFiles = self?.getAudioFiles()
                self?.presenter.presentCloudAudioFiles(MyMusicModel.FetchedFiles.Response(audioFiles: audioFiles))
            case .failure(let error):
                self?.presenter.presentError(MyMusicModel.Error.Response(error: error))
            }
        }
    }
    
    func getAudioFiles() -> [AudioFile] {
        return cloudAudioService.getAudioFiles()
    }
}
