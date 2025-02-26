//
//  CloudWorkerProtocol.swift
//  MusicApp
//
//  Created by Никита Агафонов on 09.01.2025.
//

import UIKit

protocol CloudWorkerProtocol {
    func authorize(vc: UIViewController?) async throws
    func reauthorize() async throws
    func logout() async throws
    func fetchAudio() async throws -> [AudioFile]
    func downloadAudioFile(from: String, fileName: String) async throws -> URL?
    func getAccessToken() async throws -> String
}
