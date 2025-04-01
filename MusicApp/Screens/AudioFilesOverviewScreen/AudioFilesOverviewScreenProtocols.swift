protocol AudioFilesOverviewScreenBusinessLogic {
    func loadStart()
    func fetchAudioFiles()
    func refreshAudioFiles()
    func downloadAudioFiles(_ request: AudioFilesOverviewScreenModel.DownloadAudio.Request)
    func downloadAllAudioFiles()
}

protocol AudioFilesOverviewScreenDataStore {
    var audioFiles: [RemoteAudioFile] { get set }
}

protocol AudioFilesOverviewScreenPresentationLogic {
    func presentStart(_ response: AudioFilesOverviewScreenModel.Start.Response)
    func presentError(_ response: AudioFilesOverviewScreenModel.Error.Response)
    func presentAudioFiles(_ response: AudioFilesOverviewScreenModel.FetchedFiles.Response)
    func presentDownloadedAudioFiles(_ response: AudioFilesOverviewScreenModel.DownloadAudio.Response)
}

protocol AudioFilesOverviewScreenWorkerProtocol {
    func fetchAudioFilesFromStorage(for source: RemoteAudioSource) throws -> [RemoteAudioFile]
}
