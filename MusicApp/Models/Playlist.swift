import UIKit

struct Playlist: Identifiable {
    let id: UUID
    var image: UIImage
    var title: String
    var downloadedAudios: [DownloadedAudioFile]
    var remoteAudios: [RemoteAudioFile]
    
    init(
        id: UUID,
        image: UIImage? = nil,
        title: String? = nil,
        downloadedAudios: [DownloadedAudioFile] = [],
        remoteAudios: [RemoteAudioFile] = []
    ) {
        self.id = id
        self.image = image ?? UIImage(image: .icAudioImgSvg)
        self.title = (title?.isEmpty == false ? title! : "Без названия")
        self.downloadedAudios = downloadedAudios
        self.remoteAudios = remoteAudios
        
    }
}

extension Playlist {
    init(from entity: PlaylistEntity) {
        self.id = entity.id ?? UUID()
        self.image = UIImage(data: entity.image ?? Data()) ?? UIImage(image: .icAudioImgSvg)
        self.title = entity.title ?? "Без названия"
        
        self.downloadedAudios = (entity.downloadedAudios?.allObjects as? [DownloadedAudioFileEntity])?.compactMap {
            DownloadedAudioFile(from: $0)
        } ?? []
        
        self.remoteAudios = (entity.remoteAudios?.allObjects as? [RemoteAudioFileEntity])?.compactMap {
            RemoteAudioFile(from: $0)
        } ?? []
    }
}

