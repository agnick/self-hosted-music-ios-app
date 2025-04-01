import Foundation
import CoreData


extension DownloadedAudioFileEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DownloadedAudioFileEntity> {
        return NSFetchRequest<DownloadedAudioFileEntity>(entityName: "DownloadedAudioFileEntity")
    }

    @NSManaged public var artistName: String?
    @NSManaged public var downloadPath: String?
    @NSManaged public var downloadStateRaw: Int16
    @NSManaged public var durationInSeconds: Double
    @NSManaged public var id: UUID?
    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    @NSManaged public var playbackUrl: String?
    @NSManaged public var sizeInMB: Double
    @NSManaged public var playlist: PlaylistEntity?

}

extension DownloadedAudioFileEntity : Identifiable {

}
