import Foundation

protocol AudioImportBusinessLogic {
    func handleCloudServiceSelection(_ request: AudioImportModel.CloudServiceSelection.Request)
    func handleLocalFilesSelection()
    func copySelectedFilesToAppSupportFolder(_ request: AudioImportModel.LocalFiles.Request)
    func newAuthorize(_ request: AudioImportModel.NewAuth.Request)
}

protocol AudioImportPresentationLogic {
    func presentFilePicker()
    func presentAuthAlert(_ response: AudioImportModel.AuthAlert.Response)
    func presentError(_ response: AudioImportModel.Error.Response)
    
    func routeToAudioFilesOverviewScreen(_ response: AudioImportModel.Route.Response)
}

protocol AudioImportWorkerProtocol {
    func copyFilesToAppFolder(files: [URL]) async throws
}
