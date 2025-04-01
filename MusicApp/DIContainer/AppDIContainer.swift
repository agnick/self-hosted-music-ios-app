import Foundation
import GoogleAPIClientForREST
import SwiftyDropbox

final class AppDIContainer {
    // MARK: - Core
    lazy var coreDataManager = CoreDataManager()
    
    // MARK: - Google Drive
    lazy var googleDriveService = GTLRDriveService()
    lazy var googleDriveAuthManager: CloudAuthManager = {
        GoogleDriveAuthManager(driveService: googleDriveService)
    }()
    lazy var googleDriveDataManager: CloudDataManager = {
        GoogleDriveDataManager(driveService: googleDriveService, coreDataManager: coreDataManager)
    }()
    
    // MARK: - Dropbox
    lazy var dropboxAuthManager: CloudAuthManager = {
        DropboxAuthManager()
    }()
    lazy var dropboxDataManager: CloudDataManager = {
        DropboxDataManager(coreDataManager: coreDataManager)
    }()
    
    // MARK: - Cloud auth service
    lazy var cloudAuthService: CloudAuthService = {
        CloudAuthService(
            googleAuth: googleDriveAuthManager,
            dropboxAuth: dropboxAuthManager
        )
    }()
    
    // MARK: - Cloud data service
    lazy var cloudDataService: CloudDataService = {
        CloudDataService(
            googleDataManager: googleDriveDataManager,
            dropboxDataManager: dropboxDataManager,
            cloudAuthService: cloudAuthService
        )
    }()
    
    // MARK: - AudioPlayer Service
    lazy var audioPlayerService: AudioPlayerService = AudioPlayerService()
    
    // MARK: - UserDefaults Manager
    lazy var userDefaultsManager: UserDefaultsManager = UserDefaultsManager()
}
