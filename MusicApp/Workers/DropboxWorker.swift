//
//  DropboxWorker.swift
//  MusicApp
//
//  Created by Никита Агафонов on 08.01.2025.
//

import Foundation
import SwiftyDropbox
import UIKit

final class DropboxWorker: CloudWorkerProtocol {
    func authorize(vc: UIViewController?) async throws {
        guard let vc = vc else {
            throw NSError(domain: "UIViewController is required for Dropbox authorization", code: 400)
        }
        
        let scopeRequest = ScopeRequest(scopeType: .user, scopes: ["account_info.read"], includeGrantedScopes: false)
        
        await MainActor.run {
            DropboxClientsManager.authorizeFromControllerV2(
                UIApplication.shared,
                controller: vc,
                loadingStatusDelegate: nil,
                openURL: { url in UIApplication.shared.open(url, options: [:], completionHandler: nil) },
                scopeRequest: scopeRequest
            )
        }
    }
    
    func fetchAudio() async throws -> [AudioFile] {
        return []
    }
    
    func getAccessToken() async throws -> String {
        return ""
    }
    
    func reauthorize() async throws {
        throw NSError(domain: "YandexCloudWorker", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authorized"])
    }
    
    func logout() async throws {
        
    }
    
    func getDownloadRequest(urlstring: String) -> URLRequest? {
        return nil
    }
}
