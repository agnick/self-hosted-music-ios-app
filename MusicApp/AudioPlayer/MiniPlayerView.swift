import UIKit

protocol MiniPlayerViewDelegate: AnyObject {
    func miniPlayerViewDidTap(_ miniPlayerView: MiniPlayerView)
    func miniPlayerPlayPauseTapped(_ miniPlayerVie: MiniPlayerView)
    func miniPlayerNextTrackTapped(_ miniPlayerView: MiniPlayerView)
}

final class MiniPlayerView: UIView {
    // MARK: - Enums
    enum Constants {
        // trackImg settings.
        static let trackImgLeading: CGFloat = 30
        static let trackImgHeight: CGFloat = 50
        static let trackImgWidth: CGFloat = 50
        static let trackImgCornerRadius: CGFloat = 5
        
        // trackTitle settings.
        static let trackTitleFontSize: CGFloat = 13
        static let trackTitleNumberOfLines: Int = 1
        static let trackTitleLeading: CGFloat = 15
        static let trackTitleTrailing: CGFloat = 15
        static let trackTitleTop: CGFloat = 4
        
        // artistName settings.
        static let artistNameFontSize: CGFloat = 10
        static let artistNameNumberOfLines: Int = 1
        static let artistNameLeading: CGFloat = 15
        static let artistNameTrailing: CGFloat = 15
        static let artistNameBottom: CGFloat = 4
        
        // btnStack seetings.
        static let btnStackSpacing: CGFloat = 5
        static let btnStackTrailing: CGFloat = 30
        static let btnStackWidth: CGFloat = 80
    }
    
    // MARK: - Variables
    weak var delegate: MiniPlayerViewDelegate?
    private let miniPlayerViewFactory: MiniPlayerViewFactory = MiniPlayerViewFactory()
    private let audioPlayerService: AudioPlayerService = AudioPlayerService()
    
    // UI components.
    private let trackImg: UIImageView = UIImageView()
    private var trackTitle: UILabel = UILabel()
    private var artistName: UILabel = UILabel()
    private var playPauseBtn: UIButton = UIButton(type: .system)
    private var nextTrackBtn: UIButton = UIButton(type: .system)
    private let btnStack: UIStackView = UIStackView()
    
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(trackChanged(_:)), name: .AudioPlayerTrackChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayPauseBtn), name: .AudioPlayerStateChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func trackChanged(_ notification: Notification) {
        guard let track = notification.object as? AudioFile else {
            isHidden = true
            return
        }
        
        trackTitle.text = track.name
        artistName.text = track.artistName
        trackImg.image = track.trackImg
        updatePlayPauseBtn()
        isHidden = false
    }
    
    @objc private func updatePlayPauseBtn() {
        let isPlaying = audioPlayerService.isPlaying()
        let image: UIImage = isPlaying ? UIImage(image: .icPause) : UIImage(image: .icPlay)
        playPauseBtn.setImage(image, for: .normal)
    }
    
    @objc private func playPauseBtnTapped() {
        delegate?.miniPlayerPlayPauseTapped(self)
    }
    
    @objc private func nextTrackBtnTapped() {
        delegate?.miniPlayerNextTrackTapped(self)
    }
    
    @objc private func viewTapped() {
        delegate?.miniPlayerViewDidTap(self)
    }
    
    // MARK: - Private methods
    private func configureUI() {
        backgroundColor = UIColor(color: .miniPlayerColor)
        
        isHidden = true
        
        configureTrackImg()
        configureBtnStack()
        configureTrackTitle()
        configureArtistName()
        setupGesture()
    }
    
    private func configureTrackImg() {
        addSubview(trackImg)
        
        // Image settings.
        trackImg.contentMode = .scaleAspectFill
        trackImg.clipsToBounds = true
        trackImg.layer.cornerRadius = Constants.trackImgCornerRadius
        
        // Image constraints.
        trackImg.pinLeft(to: self, Constants.trackImgLeading)
        trackImg.pinCenterY(to: self)
        trackImg.setHeight(Constants.trackImgHeight)
        trackImg.setWidth(Constants.trackImgWidth)
    }
    
    private func configureTrackTitle() {
        // Title settings.
        trackTitle = miniPlayerViewFactory.trackLabel(Constants.trackTitleFontSize, .bold, .black, Constants.trackTitleNumberOfLines)
        
        addSubview(trackTitle)
        
        trackTitle.pinLeft(to: trackImg.trailingAnchor, Constants.trackTitleLeading)
        trackTitle.pinRight(to: btnStack.leadingAnchor, Constants.trackTitleTrailing)
        trackTitle.pinTop(to: trackImg, Constants.trackTitleTop)
    }
    
    private func configureArtistName() {
        // Title settings.
        artistName = miniPlayerViewFactory.trackLabel(Constants.artistNameFontSize, .medium, .systemGray, Constants.artistNameNumberOfLines)
        
        addSubview(artistName)
        
        artistName.pinLeft(to: trackImg.trailingAnchor, Constants.artistNameLeading)
        artistName.pinRight(to: btnStack.leadingAnchor, Constants.artistNameTrailing)
        artistName.pinBottom(to: trackImg, Constants.artistNameBottom)
    }
    
    private func configureBtnStack() {
        addSubview(btnStack)
        
        btnStack.axis = .horizontal
        btnStack.spacing = Constants.btnStackSpacing
        btnStack.distribution = .fillEqually
        
        playPauseBtn = miniPlayerViewFactory.trackActionBtn(UIImage(image: .icPause))
        nextTrackBtn = miniPlayerViewFactory.trackActionBtn(UIImage(image: .icNextTrack))
        
        playPauseBtn.addTarget(self, action: #selector(playPauseBtnTapped), for: .touchUpInside)
        nextTrackBtn.addTarget(self, action: #selector(nextTrackBtnTapped), for: .touchUpInside)
        
        btnStack.addArrangedSubview(playPauseBtn)
        btnStack.addArrangedSubview(nextTrackBtn)
        
        btnStack.pinRight(to: self, Constants.btnStackTrailing)
        btnStack.pinCenterY(to: self)
        btnStack.setWidth(Constants.btnStackWidth)
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tap)
    }
}
