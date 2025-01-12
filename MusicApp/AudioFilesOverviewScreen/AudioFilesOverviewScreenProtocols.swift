//
//  AudioFilesOverviewScreenProtocols.swift
//  MusicApp
//
//  Created by Никита Агафонов on 07.01.2025.
//

protocol AudioFilesOverviewScreenBusinessLogic {
    func loadStart(_ request: AudioFilesOverviewScreenModel.Start.Request)
    func fetchAudioFiles(_ request: AudioFilesOverviewScreenModel.FetchedFiles.Request)

    func getAudioFiles() -> [AudioFile]
}

protocol AudioFilesOverviewScreenPresentationLogic {
    func presentStart(_ response: AudioFilesOverviewScreenModel.Start.Response)
    func presentError(_ response: AudioFilesOverviewScreenModel.Error.Response)
    func presentAudioFiles(_ response: AudioFilesOverviewScreenModel.FetchedFiles.Response)
    
    func routeTo()
}
