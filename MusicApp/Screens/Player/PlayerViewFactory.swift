import UIKit

final class PlayerViewFactory {
    func trackLabel(_ fontSize: CGFloat, _ fontWeight: UIFont.Weight, _ textColor: UIColor, _ numberOfLines: Int) -> UILabel {
        let trackLabel: UILabel = UILabel()
        
        trackLabel.font = .systemFont(ofSize: fontSize, weight: fontWeight)
        trackLabel.numberOfLines = numberOfLines
        trackLabel.textColor = textColor
        trackLabel.lineBreakMode = .byTruncatingTail
        
        return trackLabel
    }
    
    func audioActionButton(image: UIImage, imageWidth: CGFloat, imageHight: CGFloat) -> UIButton {
        let actionButton: UIButton = UIButton(type: .system)
        
        actionButton.setImage(image.resized(to: CGSize(width: imageWidth, height: imageHight)), for: .normal)
        actionButton.tintColor = .black
        
        actionButton.imageView?.contentMode = .scaleAspectFill
                    
        return actionButton
    }
}
