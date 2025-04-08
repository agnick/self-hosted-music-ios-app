//
//  PlaylistEntity+Properties.swift
//  MusicApp
//
//  Created by Никита Агафонов on 07.04.2025.
//

import Foundation
import CoreData

extension PlaylistEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaylistEntity> {
        return NSFetchRequest<PlaylistEntity>(entityName: "PlaylistEntity")
    }

    @NSManaged public var title: String?
    @NSManaged public var image: Data?
    @NSManaged public var audioFiles: NSSet? 
}

// MARK: Generated accessors for audioFiles
extension PlaylistEntity {
    @objc(addAudioFilesObject:)
    @NSManaged public func addToAudioFiles(_ value: AudioFileEntity)

    @objc(removeAudioFilesObject:)
    @NSManaged public func removeFromAudioFiles(_ value: AudioFileEntity)

    @objc(addAudioFiles:)
    @NSManaged public func addToAudioFiles(_ values: NSSet)

    @objc(removeAudioFiles:)
    @NSManaged public func removeFromAudioFiles(_ values: NSSet)
}
