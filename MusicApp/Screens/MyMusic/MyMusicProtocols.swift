//
//  MyMusicProtocols.swift
//  MusicApp
//
//  Created by Никита Агафонов on 17.01.2025.
//

protocol MyMusicBusinessLogic {
    func loadStart(_ request: MyMusicModel.Start.Request)
    func fetchCloudAudioFiles(_ request: MyMusicModel.FetchedFiles.Request)
    func getAudioFiles() -> [AudioFile]
}

protocol MyMusicPresentationLogic {
    func presentStart(_ response: MyMusicModel.Start.Response)
    func presentError(_ response: MyMusicModel.Error.Response)
    func presentCloudAudioFiles(_ response: MyMusicModel.FetchedFiles.Response)
    
    func routeTo()
}
