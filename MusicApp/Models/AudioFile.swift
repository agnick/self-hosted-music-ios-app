import Foundation
import UIKit

protocol AudioFile {
    var id: UUID { get }
    var name: String { get set }
    var artistName: String { get set }
    var trackImg: UIImage { get set }
    var sizeInMB: Double { get }
    var durationInSeconds: Double { get }
    var playbackUrl: String { get }
}
