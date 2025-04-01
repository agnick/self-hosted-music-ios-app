import Foundation
import CryptoKit

extension UUID {
    static func fromDeterministicHash(of string: String) -> UUID? {
        let hash = SHA256.hash(data: Data(string.utf8))
        let bytes = Array(hash)
        let uuidBytes = Array(bytes.prefix(16))

        return UUID(uuid: (
            uuidBytes[0], uuidBytes[1], uuidBytes[2], uuidBytes[3],
            uuidBytes[4], uuidBytes[5],
            uuidBytes[6], uuidBytes[7],
            uuidBytes[8], uuidBytes[9],
            uuidBytes[10], uuidBytes[11], uuidBytes[12], uuidBytes[13], uuidBytes[14], uuidBytes[15]
        ))
    }
}
