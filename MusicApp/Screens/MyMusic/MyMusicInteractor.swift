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
    private let userDefaultsManager: UserDefaultsManager
    
    private var searchQuery: String = ""
    private var isEditing = false
    private var originalAudioFiles: [AudioFile] = []
    private var currentFetchTask: Task<Void, Never>?
    private var cloudAudioFiles: [AudioFile]? = nil
    private var localAudioFiles: [AudioFile]? = nil
    
    var currentService: CloudServiceType? = nil
    var isEditingModeEnabled: Bool {
        return isEditing
    }
    var currentAudioFiles: [AudioFile] = []
    var selectedTracks: Set<String> = []
    
    init (presenter: MyMusicPresentationLogic, cloudAuthService: CloudAuthService, cloudAudioService: CloudAudioService, localAudioService: LocalAudioService, audioPlayerService: AudioPlayerService, userDefaultsManager: UserDefaultsManager) {
        self.presenter = presenter
        self.cloudAuthService = cloudAuthService
        self.cloudAudioService = cloudAudioService
        self.localAudioService = localAudioService
        self.audioPlayerService = audioPlayerService
        self.userDefaultsManager = userDefaultsManager
    }
    
    func loadStart(_ request: MyMusicModel.Start.Request) {
        let cloudService = cloudAuthService.getAuthorizedService()
        currentService = cloudService
        
        presenter.presentStart(MyMusicModel.Start.Response(cloudService: cloudService))
    }
    
    func updateAudioFiles(_ request: MyMusicModel.UpdateAudio.Request) {
        currentFetchTask?.cancel()
        
        let segmentIndex = request.selectedSegmentIndex
        
        switch segmentIndex {
        case 0:
            if let _ = cloudAuthService.getAuthorizedService() {
                if let cachedCloudFiles = cloudAudioFiles, !request.isRefresh {
                    originalAudioFiles = cachedCloudFiles
                    applySortingAndFiltering()
                    presenter.presentAudioFiles(MyMusicModel.FetchedFiles.Response(audioFiles: currentAudioFiles))
                } else {
                    currentAudioFiles = []
                    presenter.presentPreLoading()
                    currentFetchTask = Task {
                        await fetchCloudAudioFiles(MyMusicModel.FetchedFiles.Request())
                    }
                }
            } else {
                currentAudioFiles = []
                presenter.presentNotConnectedMessage()
            }
        case 1:
            if let cachedLocalFiles = localAudioFiles, !request.isRefresh {
                originalAudioFiles = cachedLocalFiles
                applySortingAndFiltering()
                presenter.presentAudioFiles(MyMusicModel.FetchedFiles.Response(audioFiles: currentAudioFiles))
            } else {
                currentAudioFiles = []
                presenter.presentPreLoading()
                currentFetchTask = Task {
                    await fetchLocalAudioFiles(MyMusicModel.FetchedFiles.Request())
                }
            }
        default:
            currentAudioFiles = []
        }
    }
    
    func sortAudioFiles(_ request: MyMusicModel.Sort.Request) {
        userDefaultsManager.saveSortPreference(request.sortType, for: UserDefaultsKeys.sortAudiosKey)
        applySortingAndFiltering()
    }
    
    func searchAudioFiles(_ request: MyMusicModel.Search.Request) {
        searchQuery = request.query
        applySortingAndFiltering()
    }
    
    // delete
    func handleDeleteSelectedTracks(_ request: MyMusicModel.HandleDelete.Request) {
        let selectedSegment = request.selectedSegmentIndex
        
        switch selectedSegment {
        case 0:
            presenter.presentDeleteAlert(MyMusicModel.DeleteAlert.Response(service: cloudAuthService.getAuthorizedService()))
        case 1:
            presenter.presentDeleteAlert(MyMusicModel.DeleteAlert.Response(service: nil))
        default:
            break
        }
    }
    
    func deleteSelectedTracks(_ request: MyMusicModel.Delete.Request) {
        Task {
            do {
                for audioFile in currentAudioFiles {
                    if selectedTracks.contains(uniqueTrackID(for: audioFile)) {
                        if let cloudService = request.service {
                            try await cloudAudioService.deleteAudioFile(for: cloudService, from: audioFile.downloadPath)
                        } else {
                            try localAudioService.deleteAudioFile(filePath: audioFile.downloadPath)
                        }
                    }
                }
                
                if let _ = request.service {
                    await fetchCloudAudioFiles(MyMusicModel.FetchedFiles.Request())
                } else {
                    await fetchLocalAudioFiles(MyMusicModel.FetchedFiles.Request())
                }
            } catch {
                print(error)
            }
        }
    }
    
    // edit
    func loadEdit(_ request: MyMusicModel.Edit.Request) {
        isEditing.toggle()
        
        // Clear the set of selected tracks when entering or exiting editing mode.
        selectedTracks.removeAll()
        
        presenter.presentEdit(MyMusicModel.Edit.Response(isEditingMode: isEditing))
    }
    
    // pick all tracks
    func pickAll(_ request: MyMusicModel.PickTracks.Request) {
        let allSelected = selectedTracks.count == currentAudioFiles.count
        
        if allSelected {
            selectedTracks.removeAll()
        } else {
            selectedTracks = Set(currentAudioFiles.map {
                uniqueTrackID(for: $0)
            })
        }
        
        presenter.presentPickAll(MyMusicModel.PickTracks.Response(state: allSelected))
    }
    
    func playInOrder() {
        guard
            let firstAudioFile = currentAudioFiles.first
        else {
            return
        }
        
        audioPlayerService.play(audioFile: firstAudioFile, playlist: currentAudioFiles)
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
        if (!isEditing) {
            let selectedTrack = currentAudioFiles[request.index]
            
            audioPlayerService.play(audioFile: selectedTrack, playlist: currentAudioFiles)
        }
    }
    
    func loadSortOptions() {
        presenter.presentSortOptions()
    }
    
    func toggleTrackSelection(_ request: MyMusicModel.TrackSelection.Request) {
        let audioFile = currentAudioFiles[request.index]
        let trackID = uniqueTrackID(for: audioFile)
        let isSelected = selectedTracks.contains(trackID)
        
        if isSelected {
            selectedTracks.remove(trackID)
        } else {
            selectedTracks.insert(trackID)
        }
        
        presenter.presentTrackSelection(MyMusicModel.TrackSelection.Response(index: request.index, selectedCount: selectedTracks.count))
    }
    
    func resetCloudCache() {
        cloudAudioFiles = nil
        currentAudioFiles = []
    }
    
    func downloadTrack(_ request: MyMusicModel.Download.Request) {
        Task {
            do {
                let audioFile = request.audioFile
                
                if let service = currentService {
                    let success = try await cloudAudioService.downloadAudioFile(for: service, from: audioFile.downloadPath, fileName: audioFile.name)
                    if success {
                        print("Трек успешно загружен: \(audioFile.name)")
                    } else {
                        print("Не удалось загрузить трек: \(audioFile.name)")
                    }
                }
            } catch {
                print("Ошибка при загрузке трека: \(error)")
                await MainActor.run {
                    presenter.presentError(MyMusicModel.Error.Response(error: error))
                }
            }
        }
    }
    
    func deleteTrack(_ request: MyMusicModel.DeleteTrack.Request) {
        Task {
            do {
                let audioFile = request.audioFile
                if audioFile.source == .local {
                    try localAudioService.deleteAudioFile(filePath: audioFile.downloadPath)
                    await fetchLocalAudioFiles(MyMusicModel.FetchedFiles.Request())
                } else if let service = currentService {
                    try await cloudAudioService.deleteAudioFile(for: service, from: audioFile.downloadPath)
                    await fetchCloudAudioFiles(MyMusicModel.FetchedFiles.Request())
                }
            } catch {
                print("Ошибка при удалении трека: \(error)")
                await MainActor.run {
                    presenter.presentError(MyMusicModel.Error.Response(error: error))
                }
            }
        }
    }
    
    // MARK: - Private methods
    private func fetchCloudAudioFiles(_ request: MyMusicModel.FetchedFiles.Request) async {
        guard
            !Task.isCancelled
        else {
            return
        }
        
        guard
            let service = cloudAuthService.getAuthorizedService()
        else {
            await MainActor.run {
                presenter.presentNotConnectedMessage()
            }
            
            return
        }
        
        do {
            let audioFiles = try await cloudAudioService.fetchAudioFiles(for: service, forceRefresh: true)
            
            guard
                !Task.isCancelled
            else {
                return
            }
            
            cloudAudioFiles = audioFiles
            originalAudioFiles = audioFiles
            applySortingAndFiltering()
            
            await MainActor.run {
                presenter.presentAudioFiles(MyMusicModel.FetchedFiles.Response(audioFiles: audioFiles))
            }
        } catch {
            await MainActor.run {
                presenter.presentError(MyMusicModel.Error.Response(error: error))
            }
        }
    }
    
    private func fetchLocalAudioFiles(_ request: MyMusicModel.FetchedFiles.Request) async {
        guard
            !Task.isCancelled
        else {
            return
        }
        
        do {
            let audioFiles = try await localAudioService.getSavedAudioFiles()
            
            guard
                !Task.isCancelled
            else {
                return
            }
            
            localAudioFiles = audioFiles
            originalAudioFiles = audioFiles
            applySortingAndFiltering()
            
            await MainActor.run {
                presenter.presentAudioFiles(MyMusicModel.FetchedFiles.Response(audioFiles: audioFiles))
            }
        } catch {
            await MainActor.run {
                presenter.presentError(MyMusicModel.Error.Response(error: error))
            }
        }
    }
    
    private func applySortingAndFiltering() {
        guard
            !Task.isCancelled
        else {
            return
        }
        
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

        presenter.presentAudioFiles(MyMusicModel.FetchedFiles.Response(audioFiles: currentAudioFiles))
    }
    
    private func uniqueTrackID(for audioFile: AudioFile) -> String {
        return "\(audioFile.source.rawValue)-\(audioFile.playbackUrl)"
    }
}
