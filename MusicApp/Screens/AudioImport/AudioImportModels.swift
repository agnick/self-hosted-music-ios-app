import UIKit

enum AudioImportModel {
    enum CloudServiceSelection {
        struct Request {
            let service: RemoteAudioSource
            let vc: UIViewController
        }
    }
    
    enum NewAuth {
        struct Request {
            let currentService: RemoteAudioSource
            let newService: RemoteAudioSource
            let vc: UIViewController
        }
    }
    
    enum AuthAlert {
        struct Response {
            let currentService: RemoteAudioSource
            let newService: RemoteAudioSource
        }
        
        struct ViewModel {
            let currentService: RemoteAudioSource
            let newService: RemoteAudioSource
        }
    }
    
    enum LocalFiles {
        struct Request {
            let urls: [URL]
        }
    }
    
    enum Route {
        struct Response {
            let cloudDataService: CloudDataService
            let coreDataManager: CoreDataManager
            let service: RemoteAudioSource
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
