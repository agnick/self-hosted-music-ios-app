//
//  GoogleDriveResourceLoaderDelegate.swift
//  MusicApp
//
//  Created by Никита Агафонов on 08.04.2025.
//

import AVFoundation

final class GoogleDriveResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    private let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
        super.init()
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url, url.scheme == "streaming" else {
            return false
        }
        
        let fileId = url.lastPathComponent
        let apiUrl = "https://www.googleapis.com/drive/v3/files/\(fileId)?alt=media"
        
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                loadingRequest.finishLoading(with: error)
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                loadingRequest.finishLoading(with: NSError(domain: "Invalid response", code: 500))
                return
            }
            
            loadingRequest.dataRequest?.respond(with: data)
            loadingRequest.finishLoading()
        }.resume()
        
        return true
    }
}
