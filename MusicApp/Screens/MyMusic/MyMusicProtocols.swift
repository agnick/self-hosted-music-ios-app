//
//  MyMusicProtocols.swift
//  MusicApp
//
//  Created by Никита Агафонов on 17.01.2025.
//

protocol MyMusicBusinessLogic {
    func loadStart(_ request: MyMusicModel.Start.Request)
    func fetchCloudAudioFiles(_ request: MyMusicModel.FetchedFiles.Request)
    func fetchLocalAudioFiles(_ request: MyMusicModel.FetchedFiles.Request)
    func updateAudioFiles(for segmentIndex: Int)
    func sortAudioFiles(_ request: MyMusicModel.Sort.Request)
    func searchAudioFiles(_ request: MyMusicModel.Search.Request)
    func playInOrder(_ request: MyMusicModel.Play.Request)
}

protocol MyMusicDataStore {
    var currentAudioFiles: [AudioFile] { get set }
}

protocol MyMusicPresentationLogic {
    func presentStart(_ response: MyMusicModel.Start.Response)
    func presentError(_ response: MyMusicModel.Error.Response)
    func presentAudioFiles(_ response: MyMusicModel.FetchedFiles.Response)
    
    func routeTo()
}

protocol MyMusicWorkerProtocol {
    func saveSortPreference(_ sortType: SortType)
    func loadSortPreference() -> SortType
}
