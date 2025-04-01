import UIKit

enum EditAudioModel {
    enum Start {
        struct Response {
            let image: UIImage
            let name: String
            let artistName: String
        }
        
        struct ViewModel {
            let image: UIImage
            let name: String
            let artistName: String
        }
    }
    
    enum AudioImage {
        struct Request {
            let imageData: Any?
        }
        
        struct Response {
            let image: UIImage
        }
        
        struct ViewModel {
            let image: UIImage
        }
    }
    
    enum EditData {
        struct Request {
            let name: String
            let artistName: String
            let image: UIImage?
        }
    }
    
    enum Error {
        struct Response {
            let error: Swift.Error
        }
        
        struct ViewModel {
            let errorDescription: String
        }
    }
}

enum EditAudioError: LocalizedError {
    case imageDownloadError
    case saveFailed(Error)

    var errorDescription: String? {
        switch self {
        case .imageDownloadError:
            return "Ошибка загрузки изображения"
        case .saveFailed(let error):
            return "Не удалось сохранить данные: \(error.localizedDescription)"
        }
    }
}
