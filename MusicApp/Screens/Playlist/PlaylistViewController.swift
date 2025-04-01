import UIKit

final class PlaylistViewController: UIViewController {
    // MARK: - Enums
    enum Constants {
        // playlistImage settings.
        static let playlistImageCornerRadius: CGFloat = 10
        static let playlistImageLeading: CGFloat = 20
        static let playlistImageSize: CGFloat = 200
        
        // playlistName settings.
        static let playlistNameFontSize: CGFloat = 17
        static let playlistNameNumberOfLines: Int = 5
        static let playlistNameLeading: CGFloat = 10
        static let playlistNameTrailing: CGFloat = 20
        
        // actionButton settings.
        static let actionButtonImagePadding: CGFloat = 5
        static let actionButtonFontSize: CGFloat = 16
        
        // buttonStackView settings.
        static let buttonStackViewSpacing: CGFloat = 15
        static let buttonStackViewTop: CGFloat = 20
        static let buttonStackViewOffset: CGFloat = 20
        static let buttonStackViewHeight: CGFloat = 45
        
        // audioTable settings.
        static let audioTableViewTop: CGFloat = 10
        static let audioTableOffset: CGFloat = 20
        static let audioTableBottom: CGFloat = 10
        static let audioTableRowHeight: CGFloat = 90
    }
    
    // MARK: - Variables
    private let interactor: PlaylistBusinessLogic & PlaylistDataStore
    private let viewFactory: PlaylistViewFactory
    
    // UI Components
    private var editButton: UIBarButtonItem?
    private let playlistImage: UIImageView = UIImageView()
    private let playlistName: UILabel = UILabel()
    private var playButton: UIButton?
    private var shuffleButton: UIButton?
    private let buttonStackView: UIStackView = UIStackView()
    private let audioTable: UITableView = UITableView()
    
    // MARK: - Lifecycle
    init(interactor: PlaylistBusinessLogic & PlaylistDataStore, viewFactory: PlaylistViewFactory) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(parameters:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Configure all UI elements and layout.
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        interactor.loadPlaylistInfo()
        interactor.loadAudioFiles()
    }
    
    // MARK: - Edit actions
    @objc private func editButtonTapped() {
        interactor.loadEditor()
    }
    
    // MARK: - Player actions
    @objc private func playButtonPressed() {
        // Request interactor to play audio tracks sequentially.
        interactor.playInOrder()
    }
    
    @objc private func shuffleButtonPressed() {
        // Request interactor to shuffle the playlist and start playback.
        interactor.playShuffle()
    }
    
    // MARK: - Refresh table actions
    @objc private func refreshAudioFiles() {
        interactor.loadAudioFiles()
        audioTable.refreshControl?.endRefreshing()
    }
    
    // MARK: - Public methods
    func displayPlaylistInfo(_ viewModel: PlaylistModel.PlaylistInfo.ViewModel) {
        playlistImage.image = viewModel.playlistImage
        playlistName.text = viewModel.playlistName
    }
    
    func displayAudioFiles() {
        audioTable.reloadData()
    }
    
    func displayAudioOptions(_ viewModel: PlaylistModel.AudioOptions.ViewModel) {
        present(viewModel.alert, animated: true, completion: nil)
    }
    
    func displayPlaylistsList(_ viewModel: PlaylistModel.Playlists.ViewModel) {
        present(viewModel.alert, animated: true, completion: nil)
    }
    
    func displayError(_ viewModel: PlaylistModel.Error.ViewModel) {
        let actions = [UIAlertAction(title: "OK", style: .default)]
        
        self.presentAlert(title: "Ошибка", message: viewModel.errorDescription, actions: actions)
    }
    
    // MARK: - Private methods
    private func configureUI() {
        view.backgroundColor = UIColor(color: .background)
        
        configureNavigationBar()
        configurePlaylistImage()
        configurePlaylistName()
        configureButtonStack()
        configureAudioTable()
    }
    
    private func configureNavigationBar() {
        let editButton = UIBarButtonItem(title: "Изменить", style: .plain, target: self, action: #selector(editButtonTapped))
        
        self.editButton = editButton
        
        navigationItem.rightBarButtonItem = editButton
    }
    
    private func configurePlaylistImage() {
        view.addSubview(playlistImage)
        
        playlistImage.contentMode = .scaleAspectFill
        playlistImage.layer.cornerRadius = Constants.playlistImageCornerRadius
        playlistImage.clipsToBounds = true
        
        playlistImage.pinLeft(to: view, Constants.playlistImageLeading)
        playlistImage.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        playlistImage.setWidth(Constants.playlistImageSize)
        playlistImage.setHeight(Constants.playlistImageSize)
    }
    
    private func configurePlaylistName() {
        view.addSubview(playlistName)
        
        playlistName.textColor = .black
        playlistName.font = .systemFont(ofSize: Constants.playlistNameFontSize, weight: .bold)
        playlistName.lineBreakMode = .byWordWrapping
        playlistName.numberOfLines = Constants.playlistNameNumberOfLines
        
        playlistName.pinLeft(to: playlistImage.trailingAnchor, Constants.playlistNameLeading)
        playlistName.pinRight(to: view, Constants.playlistNameTrailing)
        playlistName.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
    }
    
    private func configureButtonStack() {
        view.addSubview(buttonStackView)
        
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = Constants.buttonStackViewSpacing
        buttonStackView.distribution = .fillEqually
        
        let playButton: UIButton = viewFactory.audioActionButton(with: UIImage(image: .icPlay), title: "Слушать", imagePadding: Constants.actionButtonImagePadding, fontSize: Constants.actionButtonFontSize)
        let shuffleButton: UIButton = viewFactory.audioActionButton(with: UIImage(image: .icShuffle), title: "Перемешать", imagePadding: Constants.actionButtonImagePadding, fontSize: Constants.actionButtonFontSize)
        
        playButton.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        shuffleButton.addTarget(self, action: #selector(shuffleButtonPressed), for: .touchUpInside)
        
        self.playButton = playButton
        self.shuffleButton = shuffleButton
        
        buttonStackView.addArrangedSubview(playButton)
        buttonStackView.addArrangedSubview(shuffleButton)
        
        buttonStackView.pinTop(to: playlistImage.bottomAnchor, Constants.buttonStackViewTop)
        buttonStackView.pinHorizontal(to: view, Constants.buttonStackViewOffset)
        buttonStackView.setHeight(Constants.buttonStackViewHeight)
    }
    
    private func configureAudioTable() {
        view.addSubview(audioTable)
        
        audioTable.backgroundColor = .clear
        audioTable.separatorStyle = .none
        
        // Set the data source and delegate for the tableView view.
        audioTable.dataSource = self
        audioTable.delegate = self
        
        // Register the cell class for reuse.
        audioTable
            .register(
                FetchedAudioCell.self,
                forCellReuseIdentifier: FetchedAudioCell.reuseId
            )
        
        audioTable.isScrollEnabled = true
        audioTable.alwaysBounceVertical = true
        audioTable.contentInset = .zero
        audioTable.contentInsetAdjustmentBehavior = .never
        
        // Refresh control.
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(color: .primary)
        refreshControl.addTarget(
            self,
            action: #selector(refreshAudioFiles),
            for: .valueChanged
        )
        audioTable.refreshControl = refreshControl
        
        // Set constraints to position the table view.
        audioTable.pinTop(to: buttonStackView.bottomAnchor, Constants.audioTableViewTop)
        audioTable.pinHorizontal(to: view, Constants.audioTableOffset)
        audioTable.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, Constants.audioTableBottom)
    }
    
    private func showMeatballsMenu(_ audioFile: AudioFile) {
        interactor.loadAudioOptions(PlaylistModel.AudioOptions.Request(audioFile: audioFile))
    }
}

// MARK: - UITableViewDataSource
extension PlaylistViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interactor.audioFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FetchedAudioCell.reuseId,
            for: indexPath
        ) as! FetchedAudioCell
        cell.delegate = self
        
        guard
            indexPath.row < interactor.audioFiles.count
        else {
            return cell
        }
        
        let audioFile = interactor.audioFiles[indexPath.row]
        var source: RemoteAudioSource? = nil
        
        if let remote = audioFile as? RemoteAudioFile {
            source = remote.source
        }
        
        cell.configure(isEditingMode: false, img: audioFile.trackImg, isSelected: false, audioName: audioFile.name, artistName: audioFile.artistName, duration: audioFile.durationInSeconds, source: source, audioFile: audioFile)
        
        cell.meatballsMenuAction = { [weak self] audioFile in
            guard let self = self else { return }
            
            self.showMeatballsMenu(audioFile)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PlaylistViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        interactor.playSelectedTrack(PlaylistModel.Play.Request(index: indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.audioTableRowHeight
    }
}

// MARK: - FetchedAudioCellDelegate
extension PlaylistViewController: FetchedAudioCellDelegate {
    func didTapCheckBox(in cell: FetchedAudioCell) {
    }
}
