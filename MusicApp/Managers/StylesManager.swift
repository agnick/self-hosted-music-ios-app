//
//  StylesManager.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.02.2025.
//

import UIKit

struct Style: Decodable {
    var name: String
    var backGroundColor: String
    var cornerRadius: CGFloat
}

final class StylesManager {
    func style(for name: String) -> Style? {
        guard
            let path = Bundle.main.path(forResource: "Styles", ofType: "txt"),
            let data = try? String(contentsOfFile: path, encoding: .utf8).data(using: .utf8),
            //  можно сделать JSONDecoder переменной.
            let styles = try? JSONDecoder().decode([Style].self, from: data)
        else {
            return nil
        }
        
        let style = styles.first(where: { $0.name == name })
        
        return style
    }
}
