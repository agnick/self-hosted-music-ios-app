//
//  YandexCloudWorker.swift
//  MusicApp
//
//  Created by Никита Агафонов on 08.01.2025.
//

import Foundation

final class YandexCloudWorker: CloudWorker {
    func authorize() async throws {
        throw NSError(domain: "YandexCloudWorker", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization required"])
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
