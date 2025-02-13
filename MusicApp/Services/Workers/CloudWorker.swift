//
//  CloudWorkerProtocol.swift
//  MusicApp
//
//  Created by Никита Агафонов on 09.01.2025.
//

import Foundation

protocol CloudWorker {
    func authorize() async throws
    func reauthorize() async throws
    func logout() async throws
    func fetchAudio() async throws -> [AudioFile]
    func getDownloadRequest(urlstring: String) async -> URLRequest?
    func getAccessToken() async throws -> String
}
