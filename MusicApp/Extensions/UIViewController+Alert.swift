import UIKit

extension UIViewController {
    func presentAlert(title: String, message: String, preferredStyle: UIAlertController.Style = .alert, actions : [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
