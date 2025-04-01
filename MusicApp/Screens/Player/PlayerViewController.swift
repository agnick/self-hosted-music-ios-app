import UIKit

final class PlayerViewController: UIViewController {
    // MARK: - Enums
    enum Constants {
        // trackImg settings.
        static let trackImgTop: CGFloat = 20
        static let trackImgOffset: CGFloat = 20
        static let trackImgCornerRadius: CGFloat = 10
        
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
    
    // States.
    private var isSeeking = false
    private var isSeekingInProgress = false
    
    // UI components
    private let trackImg: UIImageView = UIImageView()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Observer actions
    @objc private func trackChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            guard let track = notification.object as? AudioFile else {
                self.trackName?.text = "—"
                self.artistName?.text = ""
                self.trackImg.image  = UIImage(image: .icAudioImgSvg)
                
                self.progressSlider.isHidden = true
                self.currentTrackTime?.isHidden = true
                self.trackDuration?.isHidden = true
                
                self.progressSlider.value = Constants.progressSliderMinValue
                
                return
            }
            
            self.trackName?.text = track.name
            self.artistName?.text = track.artistName
            self.trackImg.image = track.trackImg
            
            self.progressSlider.isHidden = false
            self.currentTrackTime?.isHidden = false
            self.trackDuration?.isHidden = false
            
            UIView.performWithoutAnimation {
                self.progressSlider.maximumValue = Float(track.durationInSeconds)
                self.progressSlider.setValue(Constants.progressSliderMinValue, animated: false)
            }
            
            self.trackDuration?.text = self.formatDuration(track.durationInSeconds)
            self.currentTrackTime?.text = self.formatDuration(Double(self.progressSlider.value))
        }
    }
    
    @objc private func updateRepeatBtn() {
        interactor.loadRepeatState()
    }
    
    @objc private func updatePlayPauseBtn() {
        interactor.loadPlayPauseState()
    }
    
    @objc private func updateSliderPosition(_ notification: Notification) {
        guard
            !progressSlider.isHidden,
            let currentTime = notification.object as? Double,
            !isSeeking,
            !isSeekingInProgress
        else {
            return
        }
                
        UIView.performWithoutAnimation {
            progressSlider.setValue(Float(currentTime), animated: false)
        }
        
        currentTrackTime?.text = formatDuration(currentTime)
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
    
    @objc private func meatballsMenuButtonTapped() {
        interactor.loadAudioOptions()
    }
    
    @objc private func sliderTouchBegan() {
        isSeeking = true
    }

    @objc private func sliderTouchEnded() {
        isSeeking = false
        isSeekingInProgress = true
        
        interactor.rewindTrack(PlayerModel.Rewind.Request(sliderValue: progressSlider.value))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isSeekingInProgress = false
        }
    }

    @objc private func sliderValueChanged() {
        currentTrackTime?.text = formatDuration(Double(progressSlider.value))
    }

    
    // MARK: - Public methods
    func displayStart(_ viewModel: PlayerModel.Start.ViewModel) {
        trackName?.text = viewModel.trackName
        artistName?.text = viewModel.artistName
        trackImg.image = viewModel.trackImage
        
        progressSlider.maximumValue = Float(viewModel.trackDuration ?? Double(Constants.progressSliderMinValue))
        progressSlider.setValue(Float(viewModel.currentTime), animated: false)
        
        trackDuration?.text = formatDuration(viewModel.trackDuration)
        currentTrackTime?.text = formatDuration(viewModel.currentTime)
    }
    
    func displayPlayPauseState(_ viewModel: PlayerModel.PlayPause.ViewModel) {
        playPauseButton?.setImage(viewModel.playPauseImage.resized(to: CGSize(width: Constants.centralButtonsImageWidth, height: Constants.centralButtonsImageHeight)), for: .normal)
    }
    
    func displatRepeatState(_ viewModel: PlayerModel.Repeat.ViewModel) {
        repeatButton?.tintColor = viewModel.repeatImageColor
    }
    
    func displayAudioOptions(_ viewModel: PlayerModel.AudioOptions.ViewModel) {
        present(viewModel.alert, animated: true, completion: nil)
    }
    
    func displayPlaylistsList(_ viewModel: PlayerModel.Playlists.ViewModel) {
        present(viewModel.alert, animated: true, completion: nil)
    }
    
    func displayError(_ viewModel: PlayerModel.Error.ViewModel) {
        let actions = [UIAlertAction(title: "OK", style: .default)]
        
        self.presentAlert(title: "Ошибка", message: viewModel.errorDescription, actions: actions)
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
        trackImg.contentMode = .scaleAspectFill
        trackImg.clipsToBounds = true
        trackImg.layer.cornerRadius = Constants.trackImgCornerRadius
        
        // Image constraints.
        trackImg.pinTop(to: view.safeAreaLayoutGuide.topAnchor, Constants.trackImgTop)
        trackImg.pinHorizontal(to: view, Constants.trackImgOffset)
        trackImg.pinHeight(to: trackImg.widthAnchor)
    }
    
    private func configureProgressSlider() {
        view.addSubview(progressSlider)
        
        progressSlider.minimumValue = Constants.progressSliderMinValue
        progressSlider.maximumValue = Constants.progressSliderMaxDefaultValue
        
        progressSlider.addTarget(self, action: #selector(sliderTouchBegan), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(sliderTouchEnded), for: [.touchUpInside, .touchUpOutside, .touchCancel])
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
        meatballsMenuButton.addTarget(self, action: #selector(meatballsMenuButtonTapped), for: .touchUpInside)
        
        
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
