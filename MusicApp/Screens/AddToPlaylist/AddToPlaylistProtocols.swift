//
//  AddToPlaylistProtocols.swift
//  MusicApp
//
//  Created by Никита Агафонов on 06.03.2025.
//

protocol AddToPlaylistBusinessLogic {
    func toggleTrackSelection(_ request: AddToPlaylistModel.TrackSelection.Request)
    func searchAudioFiles(_ request: AddToPlaylistModel.Search.Request)
    func loadLocalAudioFiles()
    func pickAll()
    func sendSelectedTracks()
}

protocol AddToPlaylistDataStore {
    var currentAudioFiles: [AudioFile] { get set }
    var selectedTracks: Set<String> { get set }
}

protocol AddToPlaylistPresentationLogic {
    func presentLocalAudioFiles(_ response: AddToPlaylistModel.LocalAudioFiles.Response)
    func presentError(_ response: AddToPlaylistModel.Error.Response)
    func presentTrackSelection(_ response: AddToPlaylistModel.TrackSelection.Response)
    func presentPickAll(_ response: AddToPlaylistModel.PickTracks.Response)
    func presentSendSelectedTracks(_ response: AddToPlaylistModel.SendTracks.Response)
    func presentPreLoading()
    
    func routeTo()
}

protocol AddToPlaylistWorkerProtocol {
    func loadSortPreference() -> SortType
}
