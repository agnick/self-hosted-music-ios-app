import UIKit

enum RemoteAudioSource: String, CaseIterable {
    case googleDrive = "Google Drive"
    case dropbox = "Dropbox"
}

enum RemoteDownloadState: Int16 {
    case notStarted
    case downloading
    case downloaded
    case failed
}

struct RemoteAudioFile: AudioFile {
    let id: UUID
    var name: String
    var artistName: String
    var trackImg: UIImage
    var sizeInMB: Double
    var durationInSeconds: Double
    var playbackUrl: String
    var downloadPath: String
    var downloadState: RemoteDownloadState
    var source: RemoteAudioSource
}

extension RemoteAudioFile {
    init(from entity: RemoteAudioFileEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? "Без названия"
        self.artistName = entity.artistName ?? "Без названия"
        self.trackImg = UIImage(data: entity.image ?? Data()) ?? UIImage(image: .icAudioImgSvg)
        self.sizeInMB = entity.sizeInMB
        self.durationInSeconds = entity.durationInSeconds
        self.playbackUrl = entity.playbackUrl ?? ""
        self.downloadPath = entity.downloadPath ?? ""
        self.downloadState = RemoteDownloadState(rawValue: entity.downloadStateRaw) ?? .notStarted
        self.source = RemoteAudioSource(rawValue: entity.sourceRaw ?? "") ?? .googleDrive
    }
}
