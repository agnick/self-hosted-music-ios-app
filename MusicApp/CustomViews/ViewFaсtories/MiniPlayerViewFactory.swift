//
//  MiniPlayerViewFactory.swift
//  MusicApp
//
//  Created by Никита Агафонов on 01.02.2025.
//

import UIKit

final class MiniPlayerViewFactory {
    func trackLabel(_ fontSize: CGFloat, _ fontWeight: UIFont.Weight, _ textColor: UIColor, _ numberOfLines: Int) -> UILabel {
        let trackLabel: UILabel = UILabel()
        
        trackLabel.font = .systemFont(ofSize: fontSize, weight: fontWeight)
        trackLabel.numberOfLines = numberOfLines
        trackLabel.textColor = textColor
        trackLabel.lineBreakMode = .byTruncatingTail
        
        return trackLabel
    }
    
    func trackActionBtn(_ image: UIImage) -> UIButton {
        let trackActionBtn: UIButton = UIButton(type: .system)
        
        trackActionBtn.setImage(image, for: .normal)
        
        return trackActionBtn
    }
}
