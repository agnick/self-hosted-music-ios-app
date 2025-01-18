//
//  CloudWorkerProtocol.swift
//  MusicApp
//
//  Created by Никита Агафонов on 09.01.2025.
//

import Foundation

protocol CloudWorkerProtocol {
    func authorize(completion: @escaping (Result<Void, Error>) -> Void)
    func fetchAudio(completion: @escaping (Result<[AudioFile], Error>) -> Void)
    func getAccessToken(completion: @escaping (Result<String, Error>) -> Void)
    func reauthorize(completion: @escaping (Result<Void, Error>) -> Void)
    func logout(completion: @escaping (Result<Void, Error>) -> Void)
    func getDownloadRequest(urlstring: String) -> URLRequest?
}
