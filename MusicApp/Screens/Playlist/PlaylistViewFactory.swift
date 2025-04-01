import UIKit

final class PlaylistViewFactory {
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
}
