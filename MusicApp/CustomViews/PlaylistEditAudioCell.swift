import UIKit

final class PlaylistEditAudioCell: UITableViewCell {
    // MARK: - Enums
    enum Constants {
        // Wrap settings.
        static let wrapLayerCornerRadius: CGFloat = 10
        static let wrapOffsetV: CGFloat = 5
        static let wrapLeading: CGFloat = 10
        static let wrapTrailing: CGFloat = 0
        
        // audioImg settings.
        static let audioImgLeading: CGFloat = 15
        static let audioImgHeight: CGFloat = 60
        static let audioImgWidth: CGFloat = 60
        static let audioImgCornerRadius: CGFloat = 10
        
        // audioNameLabel settings.
        static let audioNameLabelFontSize: CGFloat = 16
        static let audioNameLabelLeading: CGFloat = 16
        static let audioNameLabelTrailing: CGFloat = 20
        static let audioNameLabelNumberOfLines: Int = 1
        
        // audioSourceLabel settings.
        static let audioSourceLabelFontSize: CGFloat = 10
        static let audioSourceLabelLeading: CGFloat = 16
        static let audioSourceLabelTrailing: CGFloat = 20
        static let audioSourceLabelNumberOfLines: Int = 1
        
        // artistNameLabel settings.
        static let artistNameLabelFontSize: CGFloat = 10
        static let artistNameLabelLeading: CGFloat = 16
        static let artistNameLabelTrailing: CGFloat = 20
        static let artistNameLabelNumberOfLines: Int = 1
        
        // audioDuration settings.
        static let audioDurationFontSize: CGFloat = 12
        static let audioDurationRight: CGFloat = 20
        static let audioDurationWidth: CGFloat = 30
        
        // deleteButton settings.
        static let deleteButtonSize: CGFloat = 28
    }
    
    // MARK: - Variables
    static let reuseId: String = "PlaylistEditAudioCell"
    
    // UI Components.
    private let audioImg: UIImageView = UIImageView()
    private let audioNameLabel: UILabel = UILabel()
    private let artistNameLabel: UILabel = UILabel()
    private let audioSourceLabel: UILabel = UILabel()
    private let audioDuration: UILabel = UILabel()
    private let deleteButton: UIButton = UIButton(type: .system)
    private let wrap: UIView = UIView()
    
    // Delete action
    var deleteAction: (() -> Void)?
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func deleteButtonTapped() {
        deleteAction?()
    }
    
    // MARK: - Public Methods
    func configure(img: UIImage, audioName: String, artistName: String, duration: Double?, source: RemoteAudioSource?) {
        audioImg.image = img
        audioNameLabel.text = audioName
        artistNameLabel.text = artistName
        audioSourceLabel.text = "Источник: \(source?.rawValue ?? "скачанные")"
        
        audioDuration.text = formatDuration(duration) ?? ""
    }
    
    // MARK: - Private Methods
    private func configureUI() {
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        configureDeleteButton()
        configureWrap()
        configureImportOptionImg()
        configureAudioDuration()
        configureImportOptionTitle()
        configureAudioSourceLabel()
        configureArtistNameLabel()
    }
    
    private func configureDeleteButton() {
        addSubview(deleteButton)
        
        deleteButton.setImage(UIImage(image: .icDeleteFromPlaylist), for: .normal)
        deleteButton.tintColor = .black
        
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        deleteButton.pinLeft(to: self)
        deleteButton.pinCenterY(to: self)
        deleteButton.setWidth(Constants.deleteButtonSize)
        deleteButton.setHeight(Constants.deleteButtonSize)
    }
    
    private func configureWrap() {
        addSubview(wrap)
        
        // Wrap settings.
        wrap.backgroundColor = UIColor(color: .cellsColor)
        wrap.layer.cornerRadius = Constants.wrapLayerCornerRadius
        wrap.layer.masksToBounds = true
        
        // Wrap constraints.
        wrap.pinVertical(to: self, Constants.wrapOffsetV)
        wrap.pinLeft(to: deleteButton.trailingAnchor, Constants.wrapLeading)
        wrap.pinRight(to: self, Constants.wrapTrailing)
    }
    
    private func configureImportOptionImg() {
        wrap.addSubview(audioImg)
        
        // Image settings.
        audioImg.contentMode = .scaleAspectFill
        audioImg.clipsToBounds = true
        audioImg.layer.cornerRadius = Constants.audioImgCornerRadius
        
        // Image constraints.
        audioImg.pinLeft(to: wrap, Constants.audioImgLeading)
        audioImg.pinCenterY(to: wrap)
        audioImg.setWidth(Constants.audioImgWidth)
        audioImg.setHeight(Constants.audioImgHeight)
    }
    
    private func configureImportOptionTitle() {
        wrap.addSubview(audioNameLabel)
        
        // Title settings.
        audioNameLabel.font = .systemFont(ofSize: Constants.audioNameLabelFontSize, weight: .medium)
        audioNameLabel.textColor = .black
        audioNameLabel.numberOfLines = Constants.audioNameLabelNumberOfLines
        audioNameLabel.lineBreakMode = .byTruncatingTail

        // Title constraints.
        audioNameLabel.pinLeft(to: audioImg.trailingAnchor, Constants.audioNameLabelLeading)
        audioNameLabel.pinRight(to: audioDuration.leadingAnchor, Constants.audioNameLabelTrailing)
        audioNameLabel.pinTop(to: audioImg.topAnchor)
    }
    
    private func configureAudioSourceLabel() {
        wrap.addSubview(audioSourceLabel)
        
        audioSourceLabel.font = .systemFont(ofSize: Constants.audioSourceLabelFontSize, weight: .medium)
        audioSourceLabel.textColor = UIColor(color: .primary)
        audioSourceLabel.numberOfLines = Constants.audioSourceLabelNumberOfLines
        audioNameLabel.lineBreakMode = .byTruncatingTail
        
        audioSourceLabel.pinLeft(to: audioImg.trailingAnchor, Constants.audioSourceLabelLeading)
        audioSourceLabel.pinRight(to: audioDuration.leadingAnchor, Constants.audioSourceLabelTrailing)
        audioSourceLabel.pinCenterY(to: audioImg.centerYAnchor)
    }
    
    private func configureArtistNameLabel() {
        wrap.addSubview(artistNameLabel)
        
        // Title settings.
        artistNameLabel.font = .systemFont(ofSize: Constants.artistNameLabelFontSize, weight: .medium)
        artistNameLabel.textColor = .systemGray
        artistNameLabel.numberOfLines = Constants.artistNameLabelNumberOfLines
        artistNameLabel.lineBreakMode = .byTruncatingTail
        
        // Title constraints.
        artistNameLabel.pinLeft(to: audioImg.trailingAnchor, Constants.artistNameLabelLeading)
        artistNameLabel.pinRight(to: audioDuration.leadingAnchor, Constants.artistNameLabelTrailing)
        artistNameLabel.pinBottom(to: audioImg.bottomAnchor)
    }
    
    private func configureAudioDuration() {
        wrap.addSubview(audioDuration)
        
        // Title settings.
        audioDuration.font = .systemFont(ofSize: Constants.audioDurationFontSize, weight: .light)
        audioDuration.textColor = .black
        
        // Title constraints.
        audioDuration.pinCenterY(to: wrap)
        audioDuration.pinRight(to: wrap, Constants.audioDurationRight)
        audioDuration.setWidth(Constants.audioDurationWidth)
    }
    
    private func formatDuration(_ duration: Double?) -> String? {
        guard let duration = duration else {
            return nil
        }
        
        let totalSeconds = Int(round(duration))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}
