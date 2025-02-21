//
//  PlayerViewController.swift
//  MusicApp
//
//  Created by Никита Агафонов on 19.02.2025.
//

import UIKit

final class PlayerViewController: UIViewController {
    // MARK: - Enums
    enum Constants {
        // trackImg settings
        static let trackImgTop: CGFloat = 20
        static let trackImgWidth: Double = 0.9
        
        // progressSlider settings
        static let progressSliderTop: CGFloat = 40
        static let progressSliderOffset: CGFloat = 20
    }
    
    // MARK: - Variables
    // Player screen interactor, it contains all bussiness logic.
    private var interactor: PlayerBusinessLogic
    
    // UI components
    private let trackImg: UIImageView = UIImageView(image: UIImage(image: .icAudioImgSvg))
    private let progressSlider: UISlider = UISlider()
    
    // MARK: - Lifecycle
    init(interactor: PlayerBusinessLogic) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(parameters:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Private methods for UI configuring
    private func configureUI() {
        view.backgroundColor = UIColor(color: .background)
        
        configureTrackImg()
        configureProgressSlider()
    }
    
    private func configureTrackImg() {
        view.addSubview(trackImg)
        
        // Image settings.
        trackImg.contentMode = .scaleAspectFit
        trackImg.clipsToBounds = true
        
        // Image constraints.
        trackImg.pinTop(to: view.safeAreaLayoutGuide.topAnchor, Constants.trackImgTop)
        trackImg.pinCenterX(to: view)
        trackImg.pinWidth(to: view, Constants.trackImgWidth)
        trackImg.pinHeight(to: trackImg.widthAnchor)
    }
    
    private func configureProgressSlider() {
        view.addSubview(progressSlider)
        
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = 1
        
        progressSlider.pinTop(to: trackImg.bottomAnchor, Constants.trackImgTop)
        progressSlider.pinHorizontal(to: view, Constants.progressSliderOffset)
    }
}
