import UIKit

final class AddToPlaylistViewFactory {
    func audioActionButton(with image: UIImage, title: String, imagePadding: CGFloat, fontSize: CGFloat) -> UIButton {
        let actionButton: UIButton = UIButton(type: .system)
        
        var configuration = UIButton.Configuration.filled()
        configuration.image = image
        configuration.baseBackgroundColor = UIColor(color: .buttonColor)
        configuration.baseForegroundColor = UIColor(color: .primary)
        configuration.cornerStyle = .medium
        configuration.imagePadding = imagePadding
        configuration.imagePlacement = .leading
        
        var attributedTitle = AttributedString(title)
        attributedTitle.font =
            .systemFont(
                ofSize: fontSize,
                weight: .semibold
            )
        attributedTitle.foregroundColor = UIColor(
            color: .primary
        )
        configuration.attributedTitle = attributedTitle
            
        actionButton.configuration = configuration
        
        return actionButton
    }
    
    func trackLabel(_ fontSize: CGFloat, _ fontWeight: UIFont.Weight, _ textColor: UIColor, _ numberOfLines: Int) -> UILabel {
        let trackLabel: UILabel = UILabel()
        
        trackLabel.font = .systemFont(ofSize: fontSize, weight: fontWeight)
        trackLabel.numberOfLines = numberOfLines
        trackLabel.textColor = textColor
        trackLabel.lineBreakMode = .byTruncatingTail
        
        return trackLabel
    }
}
