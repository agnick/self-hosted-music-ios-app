//
//  Color.swift
//  MusicApp
//
//  Created by Никита Агафонов on 14.01.2025.
//

import UIKit

enum Color: String {
    case primary = "AccentColor"
    case secondary = "Secondary"
    case background = "Background"
    case buttonColor = "ButtonColor"
    case cellsColor = "CellsColor"
}

extension UIColor {
    convenience init(color: Color) {
        self.init(named: color.rawValue)!
    }
}
