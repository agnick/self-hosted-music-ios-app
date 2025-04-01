import Foundation
import UIKit

final class NewPlaylistInteractor: NewPlaylistBusinessLogic, NewPlaylistDataStore {
    // MARK: - Enums
    private enum PlaylistCreationError: LocalizedError {
        case emptyName
        
        var errorDescription: String? {
            switch self {
            case .emptyName: return "Введите название плейлиста"
            }
        }
    }

    // MARK: - Dependencies
    private let presenter: NewPlaylistPresentationLogic
    private let worker: NewPlaylistWorkerProtocol
    private let coreDataManager: CoreDataManager
    private let userDefaultsManager: UserDefaultsManager
    private let cloudAuthService: CloudAuthService
    
    // MARK: - States
    var selectedTracks: [AudioFile] = []
    private var playlistImage: UIImage?
    private var playlistName: String?
    private let mode: PlaylistEditingMode
    
    // MARK: - Lifecycle
    init (mode: PlaylistEditingMode, presenter: NewPlaylistPresentationLogic, worker: NewPlaylistWorkerProtocol, coreDataManager: CoreDataManager, userDefaultsManager: UserDefaultsManager, cloudAuthService: CloudAuthService) {
        self.mode = mode
        self.presenter = presenter
        self.worker = worker
        self.coreDataManager = coreDataManager
        self.userDefaultsManager = userDefaultsManager
        self.cloudAuthService = cloudAuthService
    }
    
    // MARK: - Public methods
    func loadTrackPicker() {
        let addToPlaylistVC = AddToPlaylistAssembly.build(coreDataManager: coreDataManager, userDefaultsManager: userDefaultsManager, cloudAuthService: cloudAuthService)
        guard
            let delegate = presenter.getAddToPlaylistDelegate()
        else {
            return
        }
        
        addToPlaylistVC.delegate = delegate
        presenter.routeTo(vc: addToPlaylistVC)
    }
    
    func loadImagePicker() {
        presenter.presentImagePicker()
    }
    
    func loadPickedPlaylistImage(_ request: NewPlaylistModel.PlaylistImage.Request) {
        if let imageData = request.imageData as? UIImage {
            presenter.presentPickedPlaylistImage(NewPlaylistModel.PlaylistImage.Response(imageData: imageData))
            playlistImage = imageData
        } else {
            let error = NSError(
                domain: "NewPlaylistInteractor",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "Ошибка загрузки изображения"]
            )
            
            presenter.presentError(NewPlaylistModel.Error.Response(error: error))
            playlistImage = nil
        }
    }
    
    func loadPlaylistName(_ request: NewPlaylistModel.PlaylistName.Request) {
        playlistName = request.playlistName
    }
    
    func getCellData(_ request: NewPlaylistModel.CellData.Request) {
        guard request.index < selectedTracks.count else { return }
        
        let audioFile = selectedTracks[request.index]
        
        presenter.presentCellData(NewPlaylistModel.CellData.Response(index: request.index, audioFile: audioFile))
    }
    
    func loadSelectedTracks(_ request: NewPlaylistModel.SelectedTracks.Request) {
        for audioFile in request.audioFiles where !selectedTracks.contains(where: { $0.playbackUrl == audioFile.playbackUrl }) {
            selectedTracks.append(audioFile)
        }
        
        presenter.presentSelectedTracks()
    }
    
    func removeTrack(_ request: NewPlaylistModel.RemoveTrack.Request) {
        guard
            request.index < selectedTracks.count
        else {
            return
        }
        
        selectedTracks.remove(at: request.index)
    }
    
    func savePlaylist() {
        guard
            let name = playlistName, !name.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            presenter.presentError(NewPlaylistModel.Error.Response(error: PlaylistCreationError.emptyName))
            return
        }

        let downloaded = selectedTracks.compactMap { $0 as? DownloadedAudioFile }
        let remote = selectedTracks.compactMap { $0 as? RemoteAudioFile }
        
        let playlist: Playlist
        switch mode {
        case .create:
            playlist = Playlist(
                id: UUID(),
                image: playlistImage,
                title: name,
                downloadedAudios: downloaded,
                remoteAudios: remote
            )
        case .edit(let existing):
            playlist = Playlist(
                id: existing.id,
                image: playlistImage,
                title: name,
                downloadedAudios: downloaded,
                remoteAudios: remote
            )
        }
        
        do {
            try worker.savePlaylistToCoreData(mode: mode, playlist: playlist)
            presenter.presentPlaylistSavedSuccessfully()
        } catch {
            presenter.presentError(NewPlaylistModel.Error.Response(error: error))
        }
    }
    
    func loadHardSetImage(_ request: NewPlaylistModel.HardSetImage.Request) {
        playlistImage = request.image
    }
}
