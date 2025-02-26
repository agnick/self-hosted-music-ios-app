//
//  AudioImportProtocols.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

protocol AudioImportBusinessLogic {
    func handleCloudServiceSelection(_ request: AudioImportModel.CloudServiceSelection.Request)
    func handleLocalFilesSelection()
    func copySelectedFilesToAppSupportFolder(_ request: AudioImportModel.LocalFiles.Request) async
    func newAuthorize(_ request: AudioImportModel.NewAuth.Request)
}

protocol AudioImportPresentationLogic {
    func presentFilePicker()
    func presentAuthAlert(_ response: AudioImportModel.AuthAlert.Response)
    func presentError(_ response: AudioImportModel.Error.Response)
    
    func routeToAudioFilesOverviewScreen(service: CloudServiceType)
}
