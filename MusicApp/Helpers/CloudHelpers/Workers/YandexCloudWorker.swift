//
//  YandexCloudWorker.swift
//  MusicApp
//
//  Created by Никита Агафонов on 08.01.2025.
//

import Foundation

final class YandexCloudWorker: CloudWorkerProtocol {
    func getDownloadRequest(urlstring: String) -> URLRequest? {
        return nil
    }
    
    func getAccessToken() -> String? {
        return nil
    }
    
    func logout(completion: @escaping (Result<Void, any Error>) -> Void) {
        
    }
    
    func reauthorize(completion: @escaping (Result<Void, any Error>) -> Void) {
        
    }
    
    func getAccessToken(completion: @escaping (Result<String, any Error>) -> Void) {
        
    }
    
    func authorize(completion: @escaping (Result<Void, any Error>) -> Void) {
        
    }
    
    func fetchAudio(completion: @escaping (Result<[AudioFile], any Error>) -> Void) {
        
    }
}
