import Foundation
import CoreData


extension PlaylistEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaylistEntity> {
        return NSFetchRequest<PlaylistEntity>(entityName: "PlaylistEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var image: Data?
    @NSManaged public var title: String?
    @NSManaged public var downloadedAudios: NSSet?
    @NSManaged public var remoteAudios: NSSet?

}

// MARK: Generated accessors for downloadedAudios
extension PlaylistEntity {

    @objc(addDownloadedAudiosObject:)
    @NSManaged public func addToDownloadedAudios(_ value: DownloadedAudioFileEntity)

    @objc(removeDownloadedAudiosObject:)
    @NSManaged public func removeFromDownloadedAudios(_ value: DownloadedAudioFileEntity)

    @objc(addDownloadedAudios:)
    @NSManaged public func addToDownloadedAudios(_ values: NSSet)

    @objc(removeDownloadedAudios:)
    @NSManaged public func removeFromDownloadedAudios(_ values: NSSet)

}

// MARK: Generated accessors for remoteAudios
extension PlaylistEntity {

    @objc(addRemoteAudiosObject:)
    @NSManaged public func addToRemoteAudios(_ value: RemoteAudioFileEntity)

    @objc(removeRemoteAudiosObject:)
    @NSManaged public func removeFromRemoteAudios(_ value: RemoteAudioFileEntity)

    @objc(addRemoteAudios:)
    @NSManaged public func addToRemoteAudios(_ values: NSSet)

    @objc(removeRemoteAudios:)
    @NSManaged public func removeFromRemoteAudios(_ values: NSSet)

}

extension PlaylistEntity : Identifiable {

}
