import Foundation

extension FileManager {
    func attributesOfFileSystem() -> [FileAttributeKey: Any]? {
        try? attributesOfFileSystem(forPath: NSHomeDirectory())
    }
}
