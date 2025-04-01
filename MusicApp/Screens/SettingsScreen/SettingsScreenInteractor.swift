import Foundation

final class SettingsScreenInteractor: SettingsScreenBusinessLogic {
    // MARK: - Dependencies
    private let presenter: SettingsScreenPresentationLogic
    private let cloudAuthService: CloudAuthService
    
    // MARK: - Lifecycle
    init (presenter: SettingsScreenPresentationLogic, cloudAuthService: CloudAuthService) {
        self.presenter = presenter
        self.cloudAuthService = cloudAuthService
    }
    
    // MARK: - Public methods
    func loadStart() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "–"

        let freeSpace = FileManager.default.attributesOfFileSystem()
            .flatMap { $0[.systemFreeSize] as? NSNumber }
            .map { Double(truncating: $0) / pow(1024, 3) } ?? 0

        let usedMemory = usedAppMemoryInGB()

        let response = SettingsScreenModel.Start.Response(
            cloudService: cloudAuthService.currentService,
            appVersion: version,
            freeMemoryGB: String(format: "%.1f", freeSpace),
            usedMemoryGB: String(format: "%.1f", usedMemory)
        )

        presenter.presentStart(response)
    }
    
    func logoutFromCloudService() {
        Task {
            do {
                if let currentService = cloudAuthService.currentService {
                    try await cloudAuthService.logout(currentService)
                }
                
                loadStart()
            } catch {
                presenter.presentError(SettingsScreenModel.Error.Response(error: error))
            }
        }
    }

    // MARK: - Private memory methods
    private func usedAppMemoryInGB() -> Double {
        let fileManager = FileManager.default
        var totalSize: UInt64 = 0

        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            totalSize += folderSize(at: documentsURL)
        }

        if let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            totalSize += folderSize(at: appSupportURL)
        }

        if let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            totalSize += folderSize(at: cachesURL)
        }

        return Double(totalSize) / (1024 * 1024 * 1024)
    }
    
    private func folderSize(at url: URL) -> UInt64 {
        var size: UInt64 = 0
        let fm = FileManager.default
        
        if let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: [], errorHandler: nil) {
            for case let fileURL as URL in enumerator {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    size += UInt64(fileSize)
                }
            }
        }
        
        return size
    }
}
