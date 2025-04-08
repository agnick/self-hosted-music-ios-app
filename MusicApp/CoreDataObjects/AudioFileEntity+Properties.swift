//
//  AudioFileEntity+Properties.swift
//  MusicApp
//
//  Created by Никита Агафонов on 07.04.2025.
//

import Foundation
import CoreData

extension AudioFileEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AudioFileEntity> {
        return NSFetchRequest<AudioFileEntity>(entityName: "AudioFileEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var artistName: String?
    @NSManaged public var sizeInMB: Double
    @NSManaged public var durationInSeconds: Double
    @NSManaged public var downloadPath: String?
    @NSManaged public var playbackUrl: String?
    @NSManaged public var downloadStateRaw: Int16
    @NSManaged public var sourceRaw: String

    @NSManaged public var playlist: PlaylistEntity?
}
