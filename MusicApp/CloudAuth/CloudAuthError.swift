import Foundation

enum CloudAuthError: LocalizedError {
    case missingClientID
    case missingRootViewController
    case authorizationFailed
    case restoreFailed
    case userNotFound
    case logoutFailed
    case dropboxError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .missingClientID:
            return "Не удалось получить ключ авторизации. Проверьте настройки приложения."
        case .missingRootViewController:
            return "Не удалось получить активное окно. Попробуйте перезапустить приложение."
        case .authorizationFailed:
            return "Ошибка авторизации. Проверьте подключение к интернету и попробуйте снова."
        case .restoreFailed:
            return "Не удалось восстановить сессию. Выполните вход заново."
        case .userNotFound:
            return "Пользователь не найден. Возможно, сеанс устарел."
        case .logoutFailed:
            return "Ошибка при выходе из аккаунта. Попробуйте позже."
        case .dropboxError(let message):
            return "Ошибка Dropbox: \(message)"
        }
    }
}

