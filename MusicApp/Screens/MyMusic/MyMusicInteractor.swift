//
//  MyMusicInteractor.swift
//  MusicApp
//
//  Created by Никита Агафонов on 17.01.2025.
//

import Foundation

final class MyMusicInteractor: MyMusicBusinessLogic, MyMusicDataStore {
    private let presenter: MyMusicPresentationLogic
    private let cloudAuthService: CloudAuthService
    private let cloudAudioService: CloudAudioService
    private let localAudioService: LocalAudioService
    private let audioPlayerService: AudioPlayerService
    private let worker: MyMusicWorker
    
    private var searchQuery: String = ""
    
    var currentAudioFiles: [AudioFile] = []
    private var originalAudioFiles: [AudioFile] = []
    
    init (presenter: MyMusicPresentationLogic, cloudAuthService: CloudAuthService, cloudAudioService: CloudAudioService, localAudioService: LocalAudioService, audioPlayerService: AudioPlayerService, worker: MyMusicWorker) {
        self.presenter = presenter
        self.cloudAuthService = cloudAuthService
        self.cloudAudioService = cloudAudioService
        self.localAudioService = localAudioService
        self.audioPlayerService = audioPlayerService
        self.worker = worker
    }
    
    func loadStart(_ request: MyMusicModel.Start.Request) {
        let cloudService = cloudAuthService.getAuthorizedService()
        
        presenter.presentStart(MyMusicModel.Start.Response(cloudService: cloudService))
    }
    
    func fetchCloudAudioFiles(_ request: MyMusicModel.FetchedFiles.Request) {        
        Task {
            guard let service = cloudAuthService.getAuthorizedService() else {
                presenter.presentError(MyMusicModel.Error.Response(error: NSError(domain: "Not authorized", code: 401, userInfo: nil)))
                return
            }
            
            do {
                let audioFiles = try await cloudAudioService.fetchAudioFiles(for: service, forceRefresh: true)
                originalAudioFiles = audioFiles
                applySortingAndFiltering()
                presenter.presentAudioFiles(MyMusicModel.FetchedFiles.Response(audioFiles: audioFiles))
            } catch {
                presenter.presentError(MyMusicModel.Error.Response(error: error))
            }
        }
    }
    
    func fetchLocalAudioFiles(_ request: MyMusicModel.FetchedFiles.Request) {
        Task {
            do {
                let audioFiles = try await localAudioService.getSavedAudioFiles()
                originalAudioFiles = audioFiles
                applySortingAndFiltering()
                presenter.presentAudioFiles(MyMusicModel.FetchedFiles.Response(audioFiles: audioFiles))
            } catch {
                presenter.presentError(MyMusicModel.Error.Response(error: error))
            }
        }
    }
    
    func updateAudioFiles(for segmentIndex: Int) {
        switch segmentIndex {
        case 0:
            fetchCloudAudioFiles(MyMusicModel.FetchedFiles.Request())
        case 1:
            fetchLocalAudioFiles(MyMusicModel.FetchedFiles.Request())
        default:
            currentAudioFiles = []
        }
    }
    
    func sortAudioFiles(_ request: MyMusicModel.Sort.Request) {
        worker.saveSortPreference(request.sortType)
        applySortingAndFiltering()
    }
    
    func searchAudioFiles(_ request: MyMusicModel.Search.Request) {
        searchQuery = request.query
        applySortingAndFiltering()
    }
    
    private func applySortingAndFiltering() {
        let sortType = worker.loadSortPreference()
        
        currentAudioFiles = originalAudioFiles
        
        if !searchQuery.isEmpty {
            currentAudioFiles = currentAudioFiles.filter {
                $0.name.lowercased().contains(searchQuery.lowercased()) ||
                $0.artistName.lowercased().contains(searchQuery.lowercased())
            }
        }

        switch sortType {
        case .artistAscending:
            currentAudioFiles.sort { $0.artistName < $1.artistName }
        case .artistDescending:
            currentAudioFiles.sort { $0.artistName > $1.artistName }
        case .titleAscending:
            currentAudioFiles.sort { $0.name < $1.name }
        case .titleDescending:
            currentAudioFiles.sort { $0.name > $1.name }
        case .durationAscending:
            currentAudioFiles.sort { $0.durationInSeconds < $1.durationInSeconds }
        case .durationDescending:
            currentAudioFiles.sort { $0.durationInSeconds > $1.durationInSeconds }
        }

        presenter.presentAudioFiles(MyMusicModel.FetchedFiles.Response(audioFiles: currentAudioFiles))
    }
    
    func playInOrder() {
        guard
            let firstAudioFile = currentAudioFiles.first
        else {
            return
        }
                
        playTrack(audioFile: firstAudioFile)
    }
    
    func playShuffle() {
        guard !currentAudioFiles.isEmpty else { return }
        
        var shuffledPlaylist = currentAudioFiles
        shuffledPlaylist.shuffle()
        
        audioPlayerService.play(audioFile: shuffledPlaylist[0], playlist: shuffledPlaylist)
    }
    
    func playNextTrack() {
        audioPlayerService.playNextTrack()
    }
    
    func playSelectedTrack(_ request: MyMusicModel.Play.Request) {
        let selectedTrack = currentAudioFiles[request.index]
        
        playTrack(audioFile: selectedTrack)
    }
    
    private func getPlayableUrl(for audioFile: AudioFile) -> URL? {
        switch audioFile.source {
        case .local:
            return audioFile.url
        case .googleDrive:
            return audioFile.url
        }
    }
    
    private func playTrack(audioFile: AudioFile) {
        guard
            let playableUrl = getPlayableUrl(for: audioFile)
        else {
            presenter.presentError(MyMusicModel.Error.Response(error: NSError(domain: "PlaybackError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить URL для воспроизведения."])))
            return
        }
        
        let playableAudioFile = AudioFile(
            name: audioFile.name,
            url: playableUrl,
            sizeInMB: audioFile.sizeInMB,
            durationInSeconds: audioFile.durationInSeconds,
            artistName: audioFile.artistName,
            source: audioFile.source
        )
        
        audioPlayerService.play(audioFile: playableAudioFile, playlist: currentAudioFiles)
    }
}
