//
//  GoogleDriveResourseLoader.swift
//  MusicApp
//
//  Created by Никита Агафонов on 12.02.2025.
//

import AVFoundation

final class GoogleDriveResourseLoader: NSObject, AVAssetResourceLoaderDelegate {
    private let accessToken: String

    init(accessToken: String) {
        self.accessToken = accessToken
    }

    // Этот метод вызывается для каждого запроса данных AVAsset
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        // Проверяем наличие исходного URL (кастомный URL с нестандартной схемой "streaming")
        guard let url = loadingRequest.request.url else {
            loadingRequest.finishLoading(with: NSError(domain: "GoogleDriveResourseLoader",
                                                        code: 400,
                                                        userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return false
        }

        // Извлекаем fileId из параметров URL (ожидаем URL вида streaming://?id=FILE_ID)
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let fileId = components.queryItems?.first(where: { $0.name == "id" })?.value else {
            loadingRequest.finishLoading(with: NSError(domain: "GoogleDriveResourseLoader",
                                                        code: 400,
                                                        userInfo: [NSLocalizedDescriptionKey: "Invalid File ID"]))
            return false
        }

        // Формируем реальный URL для API Google Drive
        let streamUrlString = "https://www.googleapis.com/drive/v3/files/\(fileId)?alt=media"
        guard let streamUrl = URL(string: streamUrlString) else {
            loadingRequest.finishLoading(with: NSError(domain: "GoogleDriveResourseLoader",
                                                        code: 400,
                                                        userInfo: [NSLocalizedDescriptionKey: "Invalid Streaming URL"]))
            return false
        }

        var newRequest = URLRequest(url: streamUrl)
        // Добавляем заголовок авторизации
        newRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        // Если AVPlayer запросил определённый диапазон байт – добавляем соответствующий заголовок
        if let dataRequest = loadingRequest.dataRequest {
            let requestedOffset = dataRequest.requestedOffset
            let requestedLength = dataRequest.requestedLength
            let rangeHeader = "bytes=\(requestedOffset)-\(requestedOffset + Int64(requestedLength) - 1)"
            newRequest.addValue(rangeHeader, forHTTPHeaderField: "Range")
        }

        // Выполняем запрос
        let task = URLSession.shared.dataTask(with: newRequest) { data, response, error in
            if let error = error {
                loadingRequest.finishLoading(with: error)
                return
            }

            // Заполняем информацию о контенте (тип, длину, поддержку диапазонов)
            if let httpResponse = response as? HTTPURLResponse,
               let contentInfoRequest = loadingRequest.contentInformationRequest {
                contentInfoRequest.contentType = httpResponse.mimeType
                if let contentRange = httpResponse.allHeaderFields["Content-Range"] as? String {
                    // Формат заголовка: "bytes start-end/total"
                    let parts = contentRange.components(separatedBy: "/")
                    if parts.count == 2,
                       let totalSize = Int64(parts[1].trimmingCharacters(in: .whitespaces)) {
                        contentInfoRequest.contentLength = totalSize
                    }
                } else if let contentLengthStr = httpResponse.allHeaderFields["Content-Length"] as? String,
                          let contentLength = Int64(contentLengthStr) {
                    contentInfoRequest.contentLength = contentLength
                }
                contentInfoRequest.isByteRangeAccessSupported = true
            }

            if let data = data {
                loadingRequest.dataRequest?.respond(with: data)
                loadingRequest.finishLoading()
            } else {
                loadingRequest.finishLoading(with: NSError(domain: "GoogleDriveResourseLoader",
                                                            code: 500,
                                                            userInfo: [NSLocalizedDescriptionKey: "No data received"]))
            }
        }

        task.resume()
        return true
    }
}
