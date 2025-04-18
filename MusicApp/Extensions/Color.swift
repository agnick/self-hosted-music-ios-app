import UIKit

enum Color: String {
    case primary = "AccentColor"
    case secondary = "Secondary"
    case background = "Background"
    case buttonColor = "ButtonColor"
    case cellsColor = "CellsColor"
    case miniPlayerColor = "MiniPlayerColor"
}

extension UIColor {
    convenience init(color: Color) {
        self.init(named: color.rawValue)!
    }
}
