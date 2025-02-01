//
//  CloudWorkerProtocol.swift
//  MusicApp
//
//  Created by Никита Агафонов on 09.01.2025.
//

import Foundation

protocol CloudWorkerProtocol {
    func authorize() async throws
    func fetchAudio() async throws -> [AudioFile]
    func getAccessToken() async throws -> String
    func reauthorize() async throws
    func logout() async throws
    
    func getDownloadRequest(urlstring: String) -> URLRequest?
}
