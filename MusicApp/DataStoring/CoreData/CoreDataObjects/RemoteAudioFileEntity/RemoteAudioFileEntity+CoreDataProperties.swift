import Foundation
import CoreData


extension RemoteAudioFileEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RemoteAudioFileEntity> {
        return NSFetchRequest<RemoteAudioFileEntity>(entityName: "RemoteAudioFileEntity")
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
    @NSManaged public var sourceRaw: String?
    @NSManaged public var playlist: PlaylistEntity?

}

extension RemoteAudioFileEntity : Identifiable {

}
