import UIKit

final class ImportOptionsCell: UITableViewCell {
    // MARK: - Enums
    enum ImportOptionsCellConstants {
        // Wrap settings.
        static let wrapLayerCornerRadius: CGFloat = 10
        static let wrapOffsetV: CGFloat = 5
        static let wrapOffsetH: CGFloat = 0
        
        // ImportOptionImg settings.
        static let importOptionImgTop: CGFloat = 15
        static let importOptionImgLeading: CGFloat = 15
        static let importOptionImgWidth: CGFloat = 50
        static let importOptionImgHeight: CGFloat = 50
        
        // ImportOptionTitle settings.
        static let importOptionTitleFontSize: CGFloat = 16
        static let importOptionTitleTop: CGFloat = 32
        static let importOptionTitleLeading: CGFloat = 16
        static let importOptionTitleNumberOfLines: Int = 0
    }
    
    // MARK: - Variables
    static let reuseId: String = "ImportOptionsCell"
    
    // UI Components.
    private let importOptionImg: UIImageView = UIImageView()
    private let importOptionTitle: UILabel = UILabel()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(_ img: UIImage?, _ title: String) {
        importOptionImg.image = img
        importOptionTitle.text = title
    }
    
    // MARK: - Private Methods
    private func configureUI() {
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        let wrap: UIView = UIView()
        addSubview(wrap)
        
        // Wrap settings.
        wrap.backgroundColor = UIColor(color: .cellsColor)
        wrap.layer.cornerRadius = ImportOptionsCellConstants.wrapLayerCornerRadius
        wrap.layer.masksToBounds = true
        
        // Wrap constraints.
        wrap.pinVertical(to: self, ImportOptionsCellConstants.wrapOffsetV)
        wrap.pinHorizontal(to: self, ImportOptionsCellConstants.wrapOffsetH)
        
        // Configure other UI components.
        configureImportOptionImg(wrap)
        configureImportOptionTitle(wrap)
    }
    
    private func configureImportOptionImg(_ wrap: UIView) {
        wrap.addSubview(importOptionImg)
        
        // Image settings.
        importOptionImg.contentMode = .scaleAspectFill
        importOptionImg.clipsToBounds = true
        
        // Image constraints.
        importOptionImg.pinLeft(to: wrap, ImportOptionsCellConstants.importOptionImgLeading)
        importOptionImg.pinCenterY(to: wrap)
        importOptionImg.setWidth(ImportOptionsCellConstants.importOptionImgWidth)
        importOptionImg.setHeight(ImportOptionsCellConstants.importOptionImgHeight)
    }
    
    private func configureImportOptionTitle(_ wrap: UIView) {
        wrap.addSubview(importOptionTitle)
        
        // Title settings.
        importOptionTitle.font = .systemFont(ofSize: ImportOptionsCellConstants.importOptionTitleFontSize, weight: .medium)
        importOptionTitle.textColor = .black
        importOptionTitle.numberOfLines = ImportOptionsCellConstants.importOptionTitleNumberOfLines
        
        // Title constraints.
        importOptionTitle.pinLeft(to: importOptionImg.trailingAnchor, ImportOptionsCellConstants.importOptionTitleLeading)
        importOptionTitle.pinCenterY(to: wrap)
    }
}
