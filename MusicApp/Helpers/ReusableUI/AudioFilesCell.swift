//
//  AudioFilesCell.swift
//  MusicApp
//
//  Created by Никита Агафонов on 07.01.2025.
//

import UIKit

final class AudioFilesCell: UITableViewCell {
    // MARK: - Enums
    enum AudioFilesCellConstants {
        // Wrap settings.
        static let wrapLayerCornerRadius: CGFloat = 10
        static let wrapOffsetV: CGFloat = 5
        static let wrapOffsetH: CGFloat = 0
        
        // audioImg settings.
        static let audioImgLeading: CGFloat = 15
        static let audioImgHeight: CGFloat = 50
        static let audioImgWidth: CGFloat = 50
        
        // audioNameLabel settings.
        static let audioNameLabelFontSize: CGFloat = 16
        static let audioNameLabelLeading: CGFloat = 16
        static let audioNameLabelTrailing: CGFloat = 10
        static let audioNameLabelNumberOfLines: Int = 1
        
        // audioSizeLabel settings.
        static let audioSizeLabelFontSize: CGFloat = 10
        static let audioSizeLabelLeading: CGFloat = 16
        static let audioSizeLabelNumberOfLines: Int = 0
        
        // downloadButton settings
        static let downloadButtonHeight: CGFloat = 40
        static let downloadButtonWidth: CGFloat = 40
        static let downloadButtonTrailing: CGFloat = 15
    }
    
    // MARK: - Variables
    static let reuseId: String = "AudioFilesCell"
    
    // UI Components.
    private let audioImg: UIImageView = UIImageView(image: UIImage(named: "ic-audio-img"))
    private let audioNameLabel: UILabel = UILabel()
    private let audioSizeLabel: UILabel = UILabel()
    private let downloadButton: UIButton = UIButton(type: .system)
    
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
    func configure(_ audioName: String, _ audioSize: Double) {
        audioNameLabel.text = audioName
        audioSizeLabel.text = "\(String(format: "%.1f", audioSize)) MB"
    }
    
    // MARK: - Private Methods
    private func configureUI() {
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        let wrap: UIView = UIView()
        addSubview(wrap)
        
        // Wrap settings.
        wrap.backgroundColor = UIColor(named: "CellsColor")
        wrap.layer.cornerRadius = AudioFilesCellConstants.wrapLayerCornerRadius
        wrap.layer.masksToBounds = true
        
        // Wrap constraints.
        wrap.pinVertical(to: self, AudioFilesCellConstants.wrapOffsetV)
        wrap.pinHorizontal(to: self, AudioFilesCellConstants.wrapOffsetH)
        
        // Configure other UI components.
        configureImportOptionImg(wrap)
        configureDownloadButton(wrap)
        configureImportOptionTitle(wrap)
        configureAudioSizeLabel(wrap)
    }
    
    private func configureImportOptionImg(_ wrap: UIView) {
        wrap.addSubview(audioImg)
        
        // Image settings.
        audioImg.contentMode = .scaleAspectFill
        audioImg.clipsToBounds = true
        
        // Image constraints.
        audioImg.pinLeft(to: wrap, AudioFilesCellConstants.audioImgLeading)
        audioImg.pinCenterY(to: wrap)
        audioImg.setWidth(AudioFilesCellConstants.audioImgWidth)
        audioImg.setHeight(AudioFilesCellConstants.audioImgHeight)
    }
    
    private func configureImportOptionTitle(_ wrap: UIView) {
        wrap.addSubview(audioNameLabel)
        
        // Title settings.
        audioNameLabel.font = .systemFont(ofSize: AudioFilesCellConstants.audioNameLabelFontSize, weight: .medium)
        audioNameLabel.textColor = .black
        audioNameLabel.numberOfLines = AudioFilesCellConstants.audioNameLabelNumberOfLines
        
        // Title constraints.
        audioNameLabel.pinLeft(to: audioImg.trailingAnchor, AudioFilesCellConstants.audioNameLabelLeading)
        audioNameLabel.pinRight(to: downloadButton.leadingAnchor, AudioFilesCellConstants.audioNameLabelTrailing)
        audioNameLabel.pinTop(to: audioImg.topAnchor)
    }
    
    private func configureAudioSizeLabel(_ wrap: UIView) {
        wrap.addSubview(audioSizeLabel)
        
        // Title settings.
        audioSizeLabel.font = .systemFont(ofSize: AudioFilesCellConstants.audioSizeLabelFontSize, weight: .medium)
        audioSizeLabel.textColor = .systemGray
        audioSizeLabel.numberOfLines = AudioFilesCellConstants.audioSizeLabelNumberOfLines
        
        // Title constraints.
        audioSizeLabel.pinLeft(to: audioImg.trailingAnchor, AudioFilesCellConstants.audioSizeLabelLeading)
        audioSizeLabel.pinBottom(to: audioImg.bottomAnchor)
    }
    
    private func configureDownloadButton(_ wrap: UIView) {
        wrap.addSubview(downloadButton)
        
        downloadButton.setImage(UIImage(named: "ic-audio-download"), for: .normal)
        
        downloadButton.contentMode = .scaleAspectFit
        downloadButton.clipsToBounds = true
        
        downloadButton.setHeight(AudioFilesCellConstants.downloadButtonHeight)
        downloadButton.setWidth(AudioFilesCellConstants.downloadButtonWidth)
        downloadButton.pinRight(to: wrap, AudioFilesCellConstants.downloadButtonTrailing)
        downloadButton.pinCenterY(to: wrap)
    }
}
