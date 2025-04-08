//
//  FetchedAudioCell.swift
//  MusicApp
//
//  Created by Никита Агафонов on 19.01.2025.
//

import UIKit

protocol FetchedAudioCellDelegate: AnyObject {
    func didTapCheckBox(in cell: FetchedAudioCell)
}

final class FetchedAudioCell: UITableViewCell {
    // MARK: - Enums
    enum Constants {
        // Wrap settings.
        static let wrapLayerCornerRadius: CGFloat = 10
        static let wrapOffsetV: CGFloat = 5
        static let wrapOffsetH: CGFloat = 0
        static let wrapEditingLeading: CGFloat = 5
        
        // checkBox settings.
        static let checkBoxLeft: CGFloat = 10
        static let checkBoxWidth: CGFloat = 30
        static let checkBoxHeight: CGFloat = 30
        
        // audioImg settings.
        static let audioImgLeading: CGFloat = 15
        static let audioImgHeight: CGFloat = 50
        static let audioImgWidth: CGFloat = 50
        
        // audioNameLabel settings.
        static let audioNameLabelFontSize: CGFloat = 16
        static let audioNameLabelLeading: CGFloat = 16
        static let audioNameLabelTrailing: CGFloat = 20
        static let audioNameLabelNumberOfLines: Int = 1
        
        // artistNameLabel settings.
        static let artistNameLabelFontSize: CGFloat = 10
        static let artistNameLabelLeading: CGFloat = 16
        static let artistNameLabelTrailing: CGFloat = 20
        static let artistNameLabelNumberOfLines: Int = 1
        
        // audioDuration settings.
        static let audioDurationFontSize: CGFloat = 12
        static let audioDurationRight: CGFloat = 20
        static let audioDurationWidth: CGFloat = 30
        
        // downloadButton settings
        static let meatballsMenuHeight: CGFloat = 30
        static let meatballsMenuWidth: CGFloat = 30
        static let meatballsMenuTrailing: CGFloat = 15
    }
    
    // MARK: - Variables
    static let reuseId: String = "AudioFilesCell"
    
    var audioFile: AudioFile?
    
    // Closures.
    var downloadAction: (() -> Void)?
    var meatballsMenuAction: ((AudioFile) -> Void)?
    
    // UI Components.
    private let audioImg: UIImageView = UIImageView()
    private let checkBox: UIButton = UIButton(type: .system)
    private let audioNameLabel: UILabel = UILabel()
    private let artistNameLabel: UILabel = UILabel()
    private let audioDuration: UILabel = UILabel()
    private let meatballsMenu: UIButton = UIButton(type: .system)
    private let wrap: UIView = UIView()
    
    private var wrapLeftConstraint: NSLayoutConstraint!
    private var isPicked: Bool = false
    
    weak var delegate: FetchedAudioCellDelegate?
    
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
    @objc private func downloadButtonTapped() {
        downloadAction?()
    }
    
    @objc private func meatballsMenuTapped() {
        if let audioFile = audioFile {
            meatballsMenuAction?(audioFile)
        }
    }
    
    @objc private func checkBoxTapped() {
        isPicked.toggle()
        let newImage = isPicked ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        checkBox.setImage(newImage, for: .normal)

        delegate?.didTapCheckBox(in: self)
    }
    
    // MARK: - Public Methods
    func configure(isEditingMode: Bool, img: UIImage = UIImage(image: .icAudioImg), isSelected: Bool, audioName: String, artistName: String, duration: Double?, audioFile: AudioFile) {
        self.audioFile = audioFile
        audioImg.image = img
        audioNameLabel.text = audioName
        artistNameLabel.text = artistName
        audioDuration.text = formatDuration(duration) ?? ""
        
        checkBox.isHidden = !isEditingMode
        
        updateCheckBoxState(isPicked: isSelected)
        
        if isEditingMode {
            wrapLeftConstraint.constant = Constants.checkBoxLeft + Constants.checkBoxWidth + Constants.wrapEditingLeading
            meatballsMenu.isHidden = true
        } else {
            wrapLeftConstraint.constant = Constants.wrapOffsetH
            meatballsMenu.isHidden = false
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
        
        configureCheckBox()
        configureWrap()
        configureImportOptionImg()
        configureMeatballsMenu()
        configureAudioDuration()
        configureImportOptionTitle()
        configureArtistNameLabel()
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
    
    private func configureImportOptionImg() {
        wrap.addSubview(audioImg)
        
        // Image settings.
        audioImg.contentMode = .scaleAspectFill
        audioImg.clipsToBounds = true
        
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
        audioDuration.pinRight(to: meatballsMenu.leadingAnchor, Constants.audioDurationRight)
        audioDuration.setWidth(Constants.audioDurationWidth)
    }
    
    private func configureMeatballsMenu() {
        wrap.addSubview(meatballsMenu)
        
        meatballsMenu.setImage(UIImage(image: .icMeatballsMenu), for: .normal)
        
        meatballsMenu.contentMode = .scaleAspectFit
        meatballsMenu.clipsToBounds = true
        
        meatballsMenu.setHeight(Constants.meatballsMenuHeight)
        meatballsMenu.setWidth(Constants.meatballsMenuWidth)
        meatballsMenu.pinRight(to: wrap, Constants.meatballsMenuTrailing)
        meatballsMenu.pinCenterY(to: wrap)
        
        meatballsMenu.addTarget(self, action: #selector(meatballsMenuTapped), for: .touchUpInside)
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
