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
    func sortAudioFiles(_ request: MyMusicModel.Sort.Request)
    func searchAudioFiles(_ request: MyMusicModel.Search.Request)
    func playSelectedTrack(_ request: MyMusicModel.Play.Request)
    func playInOrder()
    func playShuffle()
    func playNextTrack()
    // Delete tracks.
    func deleteTracks(_ request: MyMusicModel.Delete.Request)
    // Update AudioFiles
    func updateAudioFiles(_ request: MyMusicModel.UpdateAudio.Request)
    // Edit mode
    func loadEdit(_ request: MyMusicModel.Edit.Request)
    // Pick all
    func pickAll(_ request: MyMusicModel.PickTracks.Request)
    // Sort options
    func loadSortOptions()
    // Get Cell Data
    func getCellData(_ request: MyMusicModel.CellData.Request)
    // Select track
    func toggleTrackSelection(_ request: MyMusicModel.TrackSelection.Request)
}

protocol MyMusicDataStore {
    var currentAudioFiles: [AudioFile] { get set }
    var selectedTracks: Set<String> { get set }
}

protocol MyMusicPresentationLogic {
    func presentStart(_ response: MyMusicModel.Start.Response)
    func presentAudioFiles(_ response: MyMusicModel.FetchedFiles.Response)
    func presentPreLoading()
    func presentEdit(_ response: MyMusicModel.Edit.Response)
    func presentPickAll(_ response: MyMusicModel.PickTracks.Response)
    func presentSortOptions()
    func presentCellData(_ response: MyMusicModel.CellData.Response)
    func presentTrackSelection(_ response: MyMusicModel.TrackSelection.Response)
    func presentNotConnectedMessage()
    func presentError(_ response: MyMusicModel.Error.Response)
    
    func routeTo()
}

protocol MyMusicWorkerProtocol {
    func saveSortPreference(_ sortType: SortType)
    func loadSortPreference() -> SortType
}
