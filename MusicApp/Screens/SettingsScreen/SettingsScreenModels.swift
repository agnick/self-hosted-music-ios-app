import UIKit

enum SettingsScreenModel {
    enum Start {
        struct Response {
            let cloudService: RemoteAudioSource?
            let appVersion: String
            let freeMemoryGB: String
            let usedMemoryGB: String
        }
        
        struct ViewModel {
            let cloudServiceName: String
            let cloudServiceImage: UIImage?
            let appVersion: String
            let freeMemoryGB: String
            let usedMemoryGB: String
            let isCloudServiceConnected: Bool
        }
    }
    
    enum Error {
        struct Response {
            let error: Swift.Error
        }
        
        struct ViewModel {
            let errorDescription: String
        }
    }
}
