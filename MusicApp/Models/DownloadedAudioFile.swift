import UIKit

struct DownloadedAudioFile: AudioFile {
    let id: UUID
    var name: String
    var artistName: String
    var trackImg: UIImage
    var sizeInMB: Double
    var durationInSeconds: Double
    var playbackUrl: String
}

extension DownloadedAudioFile {
    init(from entity: DownloadedAudioFileEntity) {
        let storedPath = entity.playbackUrl ?? ""
        
        let validPath: String
        if let url = URL(string: storedPath), FileManager.default.fileExists(atPath: url.path) {
            validPath = storedPath
        } else if let id = entity.id {
            let documentsDir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let possibleExts = ["mp3", "m4a", "aac", "wav", "flac", "ogg", "alac"]
            
            var foundURL: URL?
            for ext in possibleExts {
                let candidate = documentsDir?.appendingPathComponent("\(id.uuidString).\(ext)")
                
                if let candidate = candidate, FileManager.default.fileExists(atPath: candidate.path) {
                        foundURL = candidate
                        break
                }
            }
            
            validPath = foundURL?.absoluteString ?? ""
        } else {
            validPath = ""
        }
        
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? "Без названия"
        self.artistName = entity.artistName ?? "Без названия"
        self.trackImg = UIImage(data: entity.image ?? Data()) ?? UIImage(image: .icAudioImgSvg)
        self.sizeInMB = entity.sizeInMB
        self.durationInSeconds = entity.durationInSeconds
        self.playbackUrl = validPath
    }
}
