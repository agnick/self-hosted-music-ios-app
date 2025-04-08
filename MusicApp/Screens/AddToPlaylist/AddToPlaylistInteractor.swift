//
//  AddToPlaylistInteractor.swift
//  MusicApp
//
//  Created by Никита Агафонов on 06.03.2025.
//

final class AddToPlaylistInteractor: AddToPlaylistBusinessLogic, AddToPlaylistDataStore {
    // MARK: - Variables
    private let presenter: AddToPlaylistPresentationLogic
    private let localAudioService: LocalAudioService
    private let userDefaultsManager: UserDefaultsManager
    
    var currentAudioFiles: [AudioFile] = []
    var selectedTracks: Set<String> = []
    private var originalAudioFiles: [AudioFile] = []
    private var searchQuery: String = ""
    
    // MARK: - Lifecycle
    init (presenter: AddToPlaylistPresentationLogic, localAudioService: LocalAudioService, userDefaultsManager: UserDefaultsManager) {
        self.presenter = presenter
        self.localAudioService = localAudioService
        self.userDefaultsManager = userDefaultsManager
    }
    
    // MARK: - Public methods
    func loadLocalAudioFiles() {
        Task {
            presenter.presentPreLoading()
            
            do {
                let audioFiles = try await localAudioService.getSavedAudioFiles()
                
                originalAudioFiles = audioFiles
                currentAudioFiles = audioFiles
                
                applySortingAndFiltering()
            } catch {
                presenter.presentError(AddToPlaylistModel.Error.Response(error: error))
            }
        }
    }
    
    func toggleTrackSelection(_ request: AddToPlaylistModel.TrackSelection.Request) {
        let audioFile = currentAudioFiles[request.index]
        let isSelected = selectedTracks.contains(audioFile.playbackUrl)
        
        if isSelected {
            selectedTracks.remove(audioFile.playbackUrl)
        } else {
            selectedTracks.insert(audioFile.playbackUrl)
        }
        
        presenter.presentTrackSelection(AddToPlaylistModel.TrackSelection.Response(index: request.index, selectedAudioFiles: selectedTracks))
    }
    
    func pickAll() {
        let allSelected = selectedTracks.count == currentAudioFiles.count
        
        if allSelected {
            selectedTracks.removeAll()
        } else {
            selectedTracks = Set(currentAudioFiles.map {
                $0.playbackUrl
            })
        }
        
        presenter.presentPickAll(AddToPlaylistModel.PickTracks.Response(state: allSelected, selectedAudioFiles: selectedTracks))
    }
    
    func searchAudioFiles(_ request: AddToPlaylistModel.Search.Request) {
        searchQuery = request.query
        applySortingAndFiltering()
    }
    
    func sendSelectedTracks() {
        let selectedAudioFiles = currentAudioFiles.filter {
            selectedTracks.contains($0.playbackUrl)
        }
        
        presenter.presentSendSelectedTracks(AddToPlaylistModel.SendTracks.Response(selectedAudioFiles: selectedAudioFiles))
    }
    
    // MARK: - Private methods
    private func applySortingAndFiltering() {
        let sortType = userDefaultsManager.loadSortPreference(for: UserDefaultsKeys.sortAudiosKey)
        
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
            currentAudioFiles.sort { $0.durationInSeconds ?? 0 < $1.durationInSeconds ?? 0}
        case .durationDescending:
            currentAudioFiles.sort { $0.durationInSeconds ?? 0 > $1.durationInSeconds ?? 0}
        }

        presenter.presentLocalAudioFiles(AddToPlaylistModel.LocalAudioFiles.Response(audioFiles: currentAudioFiles, selectedAudioFiles: selectedTracks))
    }
}
