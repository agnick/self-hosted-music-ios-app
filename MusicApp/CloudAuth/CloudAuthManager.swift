import UIKit

protocol CloudAuthManager {
    func authorize(vc: UIViewController?) async throws
    func reauthorize() async throws
    func logout() async throws
}
