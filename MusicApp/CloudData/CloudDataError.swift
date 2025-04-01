import Foundation

enum CloudDataError: LocalizedError {
    case serviceUnavailable
    case invalidResponse
    case invalidURL
    case decodingFailed
    case httpError(Int)
    case invalidContentType(String)
    case fileOperationFailed(Error)
    case saveFailed(Error)
    case deletionFailed(Error)
    case entityNotFound
    
    var errorDescription: String? {
        switch self {
        case .serviceUnavailable:
            return "Сервис недоступен. Проверьте подключение к интернету."
        case .invalidResponse:
            return "Неожиданный ответ сервера."
        case .invalidURL:
            return "Неверная ссылка на файл."
        case .decodingFailed:
            return "Не удалось обработать данные трека."
        case .httpError(let code):
            return "Ошибка загрузки (HTTP \(code))."
        case .invalidContentType(let type):
            return "Ожидался аудио-файл, но получен файл типа: \(type)."
        case .fileOperationFailed(let error):
            return "Ошибка при сохранении файла: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Не удалось сохранить данные: \(error.localizedDescription)"
        case .deletionFailed(let error):
            return "Не удалось удалить файл из облака: \(error.localizedDescription)"
        case .entityNotFound:
            return "Запись о файле не найдена в локальной базе."
        }
    }
}
