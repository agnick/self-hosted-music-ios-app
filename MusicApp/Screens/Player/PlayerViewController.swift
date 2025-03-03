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
        // trackImg settings.
        static let trackImgTop: CGFloat = 20
        static let trackImgWidth: Double = 0.9
        
        // progressSlider settings.
        static let progressSliderTop: CGFloat = 40
        static let progressSliderOffset: CGFloat = 20
        static let progressSliderMinValue: Float = 0
        static let progressSliderMaxDefaultValue: Float = 1
        
        // trackLabelsStack settings.
        static let trackLabelsStackSpacing: CGFloat = 5
        static let trackLabelsStackBottom: CGFloat = 20
        static let trackLabelsStackOffset: CGFloat = 20
        
        // trackName settings.
        static let trackNameFontSize: CGFloat = 17
        static let trackNameNumberOfLines: Int = 1
        
        // artistName settings.
        static let artistNameFontSize: CGFloat = 15
        static let artistNameNumberOfLines: Int = 1
        
        // actionButtonsStack settings.
        static let actionButtonsStackSpacing: CGFloat = 10
        static let actionButtonsStackBottom: CGFloat = 20
        static let actionButtonsStackOffset: CGFloat = 20
        static let centralButtonsImageWidth: CGFloat = 45
        static let centralButtonsImageHeight: CGFloat = 45
        static let sideButtonsImageWidth: CGFloat = 30
        static let sideButtonsImageHeight: CGFloat = 30
        
        // currentTrackTime settings
        static let currentTrackTimeFontSize: CGFloat = 15
        static let currentTrackTimeNumberOfLines: Int = 1
        static let currentTrackLeading: CGFloat = 20
        static let currentTrackTop: CGFloat = 10
        
        // trackDuration settings
        static let trackDurationFontSize: CGFloat = 15
        static let trackDurationNumberOfLines: Int = 1
        static let trackDurationTrailing: CGFloat = 20
        static let trackDurationTop: CGFloat = 10
    }
    
    // MARK: - Variables
    // Player screen interactor, it contains all bussiness logic.
    private let interactor: PlayerBusinessLogic
    private let viewFactory: PlayerViewFactory
    
    // UI components
    private let trackImg: UIImageView = UIImageView(image: UIImage(image: .icAudioImgSvg))
    private let progressSlider: UISlider = UISlider()
    private let trackLabelsStack: UIStackView = UIStackView()
    private let actionButtonsStack: UIStackView = UIStackView()
    
    private var trackName: UILabel?
    private var artistName: UILabel?
    private var currentTrackTime: UILabel?
    private var trackDuration: UILabel?
    private var repeatButton: UIButton?
    private var prevTrackButton: UIButton?
    private var nextTrackButton: UIButton?
    private var playPauseButton: UIButton?
    private var meatballsMenuButton: UIButton?
    
    // MARK: - Lifecycle
    init(interactor: PlayerBusinessLogic, viewFactory: PlayerViewFactory) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(trackChanged), name: .AudioPlayerTrackChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayPauseBtn), name: .AudioPlayerStateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateRepeatBtn), name: .AudioPlayerRepeatStateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSliderPosition), name: .AudioPlayerTimeChanged, object: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(parameters:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        interactor.loadStart()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Observer actions
    @objc private func trackChanged(_ notification: Notification) {
        if let track = notification.object as? AudioFile {
            trackName?.text = track.name
            artistName?.text = track.artistName
            progressSlider.maximumValue = Float(track.durationInSeconds ?? Double(Constants.progressSliderMinValue))
            progressSlider.value = Constants.progressSliderMinValue
            trackDuration?.text = formatDuration(track.durationInSeconds)
            currentTrackTime?.text = formatDuration(Double(progressSlider.value))
        }
    }
    
    @objc private func updateRepeatBtn() {
        interactor.loadRepeatState()
    }
    
    @objc private func updatePlayPauseBtn() {
        interactor.loadPlayPauseState()
    }
    
    @objc private func updateSliderPosition(_ notification: Notification) {
        if let currentTime = notification.object as? Double {
            progressSlider.value = Float(currentTime)
            currentTrackTime?.text = formatDuration(Double(progressSlider.value))
        }
    }
    
    // MARK: - Actions
    @objc private func repeatTrack() {
        interactor.repeatTrack()
    }
    
    @objc private func playPrevTrack() {
        interactor.playPrevTrack()
    }
    
    @objc private func playPause() {
        interactor.playPause()
    }
    
    @objc private func playNextTrack() {
        interactor.playNextTrack()
    }
    
    @objc private func sliderValueChanged() {
        interactor.rewindTrack(PlayerModel.Rewind.Request(sliderValue: progressSlider.value))
    }
    
    // MARK: - Public methods
    func displayStart(_ viewModel: PlayerModel.Start.ViewModel) {
        trackName?.text = viewModel.trackName
        artistName?.text = viewModel.artistName
        progressSlider.maximumValue = Float(viewModel.trackDuration ?? Double(Constants.progressSliderMinValue))
        trackDuration?.text = formatDuration(viewModel.trackDuration)
    }
    
    func displayPlayPauseState(_ viewModel: PlayerModel.PlayPause.ViewModel) {
        playPauseButton?.setImage(viewModel.playPauseImage.resized(to: CGSize(width: Constants.centralButtonsImageWidth, height: Constants.centralButtonsImageHeight)), for: .normal)
    }
    
    func displatRepeatState(_ viewModel: PlayerModel.Repeat.ViewModel) {
        repeatButton?.tintColor = viewModel.repeatImageColor
    }
    
    // MARK: - Private methods for UI configuring
    private func configureUI() {
        view.backgroundColor = UIColor(color: .background)
        
        configureTrackImg()
        configureProgressSlider()
        configureCurrentTrackTime()
        configureTrackDuration()
        configureActionButtonsStack()
        configureTrackLabelsStack()
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
        
        progressSlider.minimumValue = Constants.progressSliderMinValue
        progressSlider.maximumValue = Constants.progressSliderMaxDefaultValue
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        progressSlider.pinTop(to: trackImg.bottomAnchor, Constants.trackImgTop)
        progressSlider.pinHorizontal(to: view, Constants.progressSliderOffset)
    }
    
    private func configureCurrentTrackTime() {
        let currentTrackTime = viewFactory.trackLabel(Constants.currentTrackTimeFontSize, .semibold, .lightGray, Constants.currentTrackTimeNumberOfLines)
        
        currentTrackTime.textAlignment = .left
        
        self.currentTrackTime = currentTrackTime
        
        view.addSubview(currentTrackTime)
        
        currentTrackTime.pinTop(to: progressSlider.bottomAnchor, Constants.currentTrackTop)
        currentTrackTime.pinLeft(to: view, Constants.currentTrackLeading)
    }
    
    private func configureTrackDuration() {
        let trackDuration = viewFactory.trackLabel(Constants.trackDurationFontSize, .semibold, .lightGray, Constants.trackDurationNumberOfLines)
        
        trackDuration.textAlignment = .right
        
        self.trackDuration = trackDuration
        
        view.addSubview(trackDuration)
        
        trackDuration.pinTop(to: progressSlider.bottomAnchor, Constants.trackDurationTop)
        trackDuration.pinRight(to: view, Constants.trackDurationTrailing)
    }
    
    private func configureTrackLabelsStack() {
        view.addSubview(trackLabelsStack)
        
        trackLabelsStack.axis = .vertical
        trackLabelsStack.spacing = Constants.trackLabelsStackSpacing
        trackLabelsStack.distribution = .fillEqually
        
        let trackName: UILabel = viewFactory.trackLabel(Constants.trackNameFontSize, .semibold, .black, Constants.trackNameNumberOfLines)
        let artistName: UILabel = viewFactory.trackLabel(Constants.artistNameFontSize, .semibold, UIColor(color: .primary), Constants.artistNameNumberOfLines)
        
        trackName.textAlignment = .center
        artistName.textAlignment = .center
        
        self.trackName = trackName
        self.artistName = artistName
        
        trackLabelsStack.addArrangedSubview(trackName)
        trackLabelsStack.addArrangedSubview(artistName)
        
        trackLabelsStack.pinBottom(to: actionButtonsStack.topAnchor, Constants.trackLabelsStackBottom)
        trackLabelsStack.pinHorizontal(to: view, Constants.trackLabelsStackOffset)
    }
    
    private func configureActionButtonsStack() {
        view.addSubview(actionButtonsStack)
        
        actionButtonsStack.axis = .horizontal
        actionButtonsStack.spacing = Constants.actionButtonsStackSpacing
        actionButtonsStack.distribution = .fillEqually
        
        let repeatButton = viewFactory.audioActionButton(image: UIImage(image: .icRepeat), imageWidth: Constants.sideButtonsImageWidth, imageHight: Constants.sideButtonsImageHeight)
        let prevTrackButton = viewFactory.audioActionButton(image: UIImage(image: .icPrevTrack), imageWidth: Constants.centralButtonsImageWidth, imageHight: Constants.centralButtonsImageHeight)
        let playPauseButton = viewFactory.audioActionButton(image: UIImage(image: .icPlay), imageWidth: Constants.centralButtonsImageWidth, imageHight: Constants.centralButtonsImageHeight)
        let nextTrackButton = viewFactory.audioActionButton(image: UIImage(image: .icNextTrack), imageWidth: Constants.centralButtonsImageWidth, imageHight: Constants.centralButtonsImageHeight)
        let meatballsMenuButton = viewFactory.audioActionButton(image: UIImage(image: .icMeatballsMenu), imageWidth: Constants.sideButtonsImageWidth, imageHight: Constants.sideButtonsImageHeight)
        
        self.repeatButton = repeatButton
        self.prevTrackButton = prevTrackButton
        self.playPauseButton = playPauseButton
        self.nextTrackButton = nextTrackButton
        self.meatballsMenuButton = meatballsMenuButton
        
        // Add targets.
        repeatButton.addTarget(self, action: #selector(repeatTrack), for: .touchUpInside)
        prevTrackButton.addTarget(self, action: #selector(playPrevTrack), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(playPause), for: .touchUpInside)
        nextTrackButton.addTarget(self, action: #selector(playNextTrack), for: .touchUpInside)
        
        // Add buttons to view.
        [repeatButton, prevTrackButton, playPauseButton, nextTrackButton, meatballsMenuButton].forEach {
            actionButtonsStack.addArrangedSubview($0)
        }
        
        actionButtonsStack.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, Constants.actionButtonsStackBottom)
        actionButtonsStack.pinHorizontal(to: view, Constants.actionButtonsStackOffset)
    }
    
    // MARK: - Utils methods
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
