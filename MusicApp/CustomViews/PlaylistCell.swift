//
//  PlaylistCell.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.03.2025.
//

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
        
        // playlistImg settings.
        static let playlistImgTop: CGFloat = 15
        static let playlistImgLeading: CGFloat = 15
        static let playlistImgWidth: CGFloat = 50
        static let playlistImgHeight: CGFloat = 50
        
        // playlistTitle settings.
        static let playlistTitleFontSize: CGFloat = 16
        static let playlistTitleTop: CGFloat = 32
        static let playlistTitleLeading: CGFloat = 16
        static let playlistTitleNumberOfLines: Int = 0
    }
    
    // MARK: - Variables
    static let reuseId: String = "PlaylistCell"
    weak var delegate: PlaylistCellDelegate?
    
    // UI components.
    private let playlistImg: UIImageView = UIImageView()
    private let playlistTitle: UILabel = UILabel()
    
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
        wrap.layer.cornerRadius = Constants.wrapLayerCornerRadius
        wrap.layer.masksToBounds = true
        
        // Wrap constraints.
        wrap.pinVertical(to: self, Constants.wrapOffsetV)
        wrap.pinHorizontal(to: self, Constants.wrapOffsetH)
        
        // Configure other UI components.
        configurePlaylistImg(wrap)
        configurePlaylistTitle(wrap)
    }
    
    private func configurePlaylistImg(_ wrap: UIView) {
        wrap.addSubview(playlistImg)
        
        // Image settings.
        playlistImg.contentMode = .scaleAspectFill
        playlistImg.clipsToBounds = true
        
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
        playlistTitle.pinCenterY(to: wrap)
    }
}
