import UIKit

protocol PlaylistCellDelegate: AnyObject {
    func didTapCheckBox(in cell: PlaylistCell)
}

final class PlaylistCell: UITableViewCell {
    // MARK: - Enums
    enum Constants {
        // Wrap settings.
        static let wrapLayerCornerRadius: CGFloat = 10
        static let wrapOffsetV: CGFloat = 5
        static let wrapOffsetH: CGFloat = 0
        static let wrapEditingLeading: CGFloat = 5
        
        // playlistImg settings.
        static let playlistImgLeading: CGFloat = 15
        static let playlistImgWidth: CGFloat = 60
        static let playlistImgHeight: CGFloat = 60
        static let playlistImgCornerRadius: CGFloat = 10
        
        // playlistTitle settings.
        static let playlistTitleFontSize: CGFloat = 16
        static let playlistTitleLeading: CGFloat = 15
        static let playlistTitleTrailing: CGFloat = 50
        static let playlistTitleNumberOfLines: Int = 1
        
        // checkBox settings.
        static let checkBoxLeft: CGFloat = 10
        static let checkBoxWidth: CGFloat = 30
        static let checkBoxHeight: CGFloat = 30
    }
    
    // MARK: - Variables
    static let reuseId: String = "PlaylistCell"
    weak var delegate: PlaylistCellDelegate?
    
    // UI components.
    private let wrap: UIView = UIView()
    private var wrapLeftConstraint: NSLayoutConstraint?
    private let playlistImg: UIImageView = UIImageView()
    private let playlistTitle: UILabel = UILabel()
    private let checkBox: UIButton = UIButton(type: .system)
    
    // States
    private var isPicked: Bool = false
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
        accessoryType = .disclosureIndicator
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func checkBoxTapped() {
        isPicked.toggle()
        let newImage = isPicked ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        checkBox.setImage(newImage, for: .normal)

        delegate?.didTapCheckBox(in: self)
    }
    
    // MARK: - Public Methods
    func configure(_ img: UIImage?, _ title: String, isEditingMode: Bool, isSelected: Bool) {
        playlistImg.image = img
        playlistTitle.text = title
        checkBox.isHidden = !isEditingMode
        updateCheckBoxState(isPicked: isSelected)
        
        if isEditingMode {
            wrapLeftConstraint?.constant = Constants.checkBoxLeft + Constants.checkBoxWidth + Constants.wrapEditingLeading
        } else {
            wrapLeftConstraint?.constant = Constants.wrapOffsetH
        }
        
        layoutIfNeeded()
    }
    
    func updateCheckBoxState(isPicked: Bool) {
        self.isPicked = isPicked
        let newImage = isPicked ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        checkBox.setImage(newImage, for: .normal)
    }
    
    // MARK: - Private Methods
    private func configureUI() {
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        // Configure other UI components.
        configureWrap()
        configureCheckBox()
        configurePlaylistImg(wrap)
        configurePlaylistTitle(wrap)
    }
    
    private func configureWrap() {
        addSubview(wrap)
        
        // Wrap settings.
        wrap.backgroundColor = UIColor(color: .cellsColor)
        wrap.layer.cornerRadius = Constants.wrapLayerCornerRadius
        wrap.layer.masksToBounds = true
        
        // Wrap constraints.
        wrap.pinVertical(to: self, Constants.wrapOffsetV)
        wrap.pinRight(to: self, Constants.wrapOffsetH)
        
        wrapLeftConstraint = wrap.pinLeft(to: self, Constants.wrapOffsetH)
    }
    
    private func configurePlaylistImg(_ wrap: UIView) {
        wrap.addSubview(playlistImg)
        
        // Image settings.
        playlistImg.contentMode = .scaleAspectFill
        playlistImg.clipsToBounds = true
        playlistImg.layer.cornerRadius = Constants.playlistImgCornerRadius
        
        // Image constraints.
        playlistImg.pinLeft(to: wrap, Constants.playlistImgLeading)
        playlistImg.pinCenterY(to: wrap)
        playlistImg.setWidth(Constants.playlistImgWidth)
        playlistImg.setHeight(Constants.playlistImgHeight)
    }
    
    private func configurePlaylistTitle(_ wrap: UIView) {
        wrap.addSubview(playlistTitle)
        
        // Title settings.
        playlistTitle.font = .systemFont(ofSize: Constants.playlistTitleFontSize, weight: .medium)
        playlistTitle.textColor = .black
        playlistTitle.numberOfLines = Constants.playlistTitleNumberOfLines
        
        // Title constraints.
        playlistTitle.pinLeft(to: playlistImg.trailingAnchor, Constants.playlistTitleLeading)
        playlistTitle.pinRight(to: wrap.trailingAnchor, Constants.playlistTitleTrailing)
        playlistTitle.pinCenterY(to: wrap)
    }
    
    private func configureCheckBox() {
        addSubview(checkBox)

        checkBox.setImage(UIImage(systemName: "circle"), for: .normal)
        checkBox.tintColor = UIColor(color: .primary)
        checkBox.isHidden = true
        
        checkBox.addTarget(self, action: #selector(checkBoxTapped), for: .touchUpInside)
        
        checkBox.pinLeft(to: self)
        checkBox.pinCenterY(to: self)
        checkBox.setWidth(Constants.checkBoxWidth)
        checkBox.setHeight(Constants.checkBoxHeight)
    }
}
