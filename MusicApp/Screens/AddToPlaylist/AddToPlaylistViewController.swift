import UIKit

protocol AddToPlaylistDelegate: AnyObject {
    func didSelectAudioFiles(_ audioFiles: [AudioFile])
}

final class AddToPlaylistViewController: UIViewController {
    // MARK: - Enums
    private enum Constants {
        // titleLabel settings.
        static let titleLabelFontSize: CGFloat = 32
        static let titleLabelLeading: CGFloat = 20
        
        // searchBar settings.
        static let searchBarTop: CGFloat = 20
        static let searchBarLeading: CGFloat = 20
        static let searchBarTrailing: CGFloat = 20
        static let searchBarHeight: CGFloat = 35
        static let searchBarTextFieldMargin: CGFloat = 0
        
        // pickAllButton settings.
        static let pickAllButtonOffsetX: CGFloat = 20
        static let pickAllButtonTop: CGFloat = 10
        static let pickAllButtonHeight: CGFloat = 45
        
        // actionButton settings.
        static let actionButtonImagePadding: CGFloat = 5
        static let actionButtonFontSize: CGFloat = 16
        
        // audioTable settings.
        static let audioTableViewTop: CGFloat = 10
        static let audioTableOffset: CGFloat = 20
        static let audioTableBottom: CGFloat = 10
        static let audioTableRowHeight: CGFloat = 90
        
        // activityIndicator settings.
        static let activityIndicatorTop: CGFloat = 20
        
        // tracksCountLabel settings.
        static let tracksCountLabelFontSize: CGFloat = 12
        static let tracksCountLabelNumberOfLines: Int = 1
        
        // selectedTracksCountLabel settings.
        static let selectedTracksCountLabelFontSize: CGFloat = 12
        static let selectedTracksCountLabelNumberOfLines: Int = 1
        
        // trackCounterStackView settings.
        static let trackCounterStackViewBottom: CGFloat = 10
        static let trackCounterStackViewOffset: CGFloat = 20
    }
    
    private enum Section: Int, CaseIterable {
        case cloud
        case downloaded
        
        var title: String {
            switch self {
            case .cloud:
                return "Облачные треки"
            case .downloaded:
                return "Скачанные треки"
            }
        }
    }
    
    // MARK: - Variables
    // AddToPlaylist screen interactor, it contains all bussiness logic.
    private let interactor: (AddToPlaylistBusinessLogic & AddToPlaylistDataStore)
    // View factory
    private let viewFactory: AddToPlaylistViewFactory
    // Delegate
    weak var delegate: AddToPlaylistDelegate?
    
    /* UI components */
    // Labels.
    private let titleLabel: UILabel = UILabel()
    private var tracksCountLabel: UILabel?
    private var selectedTracksCountLabel: UILabel?
    
    // Buttons.
    private var cancelButton: UIBarButtonItem?
    private var addButton: UIBarButtonItem?
    private var pickAllButton: UIButton?
    
    // Other components.
    private let searchBar: UISearchBar = UISearchBar(frame: .zero)
    private let audioTable: UITableView = UITableView(frame: .zero)
    private let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(
        style: .medium
    )
    private let trackCounterStackView: UIStackView = UIStackView()
    
    // Section helpers
    private var cloudFiles: [AudioFile] {
        interactor.currentAudioFiles.filter { $0 is RemoteAudioFile }
    }
    
    private var downloadedFiles: [AudioFile] {
        interactor.currentAudioFiles.filter { $0 is DownloadedAudioFile }
    }
    
    // MARK: - Lifecycle
    init(interactor: (AddToPlaylistBusinessLogic & AddToPlaylistDataStore), viewFactory: AddToPlaylistViewFactory) {
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
        
        navigationItem.setHidesBackButton(true, animated: false)
        
        // Configure all UI elements and layout.
        configureUI()
        
        interactor.loadAudioFiles()
    }
    
    // MARK: - Public methods
    func displayPreLoading(_ viewModel: AddToPlaylistModel.PreLoading.ViewModel) {
        // Start the activity indicator to show loading progress.
        activityIndicator.startAnimating()
    }
    
    func displayAudioFiles(_ viewModel: AddToPlaylistModel.AudioFiles.ViewModel) {
        activityIndicator.stopAnimating()
        audioTable.reloadData()
        
        searchBar.isHidden = false
        pickAllButton?.isHidden = false
        
        tracksCountLabel?.text = "Всего треков: \(viewModel.filesCount)"
        setSelectedTracksCount(viewModel.selectedFilesCount)
    }
    
    func displayTrackSelection(_ viewModel: AddToPlaylistModel.TrackSelection.ViewModel) {
        audioTable.reloadRows(at: [viewModel.indexPath], with: .automatic)
        
        addButton?.isEnabled = viewModel.isSelected
        setSelectedTracksCount(viewModel.selectedAudioFilesCount)
    }
    
    func displayPickAll(_ viewModel: AddToPlaylistModel.PickTracks.ViewModel) {
        pickAllButton?.setTitle(viewModel.buttonTitle, for: .normal)
        audioTable.reloadData()
        addButton?.isEnabled = !viewModel.state
        setSelectedTracksCount(viewModel.selectedAudioFilesCount)
    }
    
    func displayError(
        _ viewModel: AddToPlaylistModel.Error.ViewModel
    ) {
        let actions = [UIAlertAction(title: "OK", style: .default)]
        
        self.presentAlert(
            title: "Ошибка",
            message: viewModel.errorDescription,
            actions: actions
        )
    }
    
    // MARK: - Tab bar actions
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func addButtonTapped() {
        interactor.sendSelectedTracks()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Pick actions
    @objc private func pickAllButtonPressed() {
        interactor.pickAll()
    }
    
    // MARK: - Private methods for UI configuring
    private func configureUI() {
        view.backgroundColor = UIColor(color: .background)
        
        configureNavigationBar()
        configureTitleLabel()
        configureSearchBar()
        configurePickAllButton()
        configureActivityIndicator()
        configureTracksCounterStackView()
        configureAudioTable()
    }
    
    private func configureNavigationBar() {
        let cancelButton = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(cancelButtonTapped))
        
        let addButton = UIBarButtonItem(title: "Добавить", style: .plain, target: self, action: #selector(addButtonTapped))
        
        addButton.isEnabled = false
        
        self.cancelButton = cancelButton
        self.addButton = addButton
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func configureTitleLabel() {
        view.addSubview(titleLabel)
        
        // Setting the font and text color.
        titleLabel.font =
            .systemFont(
                ofSize: Constants.titleLabelFontSize,
                weight: .bold
            )
        titleLabel.textColor = .black
        titleLabel.text = "Моя музыка"
        
        // Set constraints to position the title label.
        titleLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.pinLeft(to: view, Constants.titleLabelLeading)
    }
    
    private func configureSearchBar() {
        view.addSubview(searchBar)
        
        searchBar.placeholder = "Искать в моей музыке"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
        let textField = searchBar.searchTextField as UITextField
        
        textField.clearButtonMode = .never
        
        textField.pinLeft(to: searchBar.leadingAnchor, Constants.searchBarTextFieldMargin)
        textField.pinTop(to: searchBar.topAnchor, Constants.searchBarTextFieldMargin)
        textField.pinRight(to: searchBar.trailingAnchor, Constants.searchBarTextFieldMargin)
        textField.pinBottom(to: searchBar.bottomAnchor, Constants.searchBarTextFieldMargin)
        
        searchBar.isHidden = true
        
        searchBar.pinTop(to: titleLabel.bottomAnchor, Constants.searchBarTop)
        searchBar.pinLeft(to: view, Constants.searchBarLeading)
        searchBar.pinRight(to: view, Constants.searchBarTrailing)
        searchBar.setHeight(Constants.searchBarHeight)
    }
    
    private func configurePickAllButton() {
        let pickAllButton: UIButton = viewFactory.audioActionButton(with: UIImage(image: .icCheck), title: "Выбрать все", imagePadding: Constants.actionButtonImagePadding, fontSize: Constants.actionButtonFontSize)
        
        view.addSubview(pickAllButton)
        
        pickAllButton.addTarget(self, action: #selector(pickAllButtonPressed), for: .touchUpInside)
        
        pickAllButton.isHidden = true
        
        pickAllButton.pinHorizontal(to: view, Constants.pickAllButtonOffsetX)
        pickAllButton.pinTop(to: searchBar.bottomAnchor, Constants.pickAllButtonTop)
        pickAllButton.setHeight(Constants.pickAllButtonHeight)
        
        self.pickAllButton = pickAllButton
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
        
        // Set constraints to position the table view.
        audioTable
            .pinTop(
                to: pickAllButton?.bottomAnchor ?? searchBar.bottomAnchor, Constants.audioTableViewTop)
        audioTable.pinHorizontal(to: view, Constants.audioTableOffset)
        audioTable.pinBottom(to: trackCounterStackView.topAnchor, Constants.audioTableBottom)
    }
    
    private func configureActivityIndicator() {
        view.addSubview(activityIndicator)
        
        // Set indicator settings.
        activityIndicator.color = UIColor(color: .primary)
        activityIndicator.hidesWhenStopped = true
        
        // Set constraints to position the indicator.
        activityIndicator.pinTop(to: titleLabel.bottomAnchor, Constants.activityIndicatorTop)
        activityIndicator.pinCenterX(to: view)
    }
    
    private func configureTracksCounterStackView() {
        view.addSubview(trackCounterStackView)
        
        trackCounterStackView.axis = .vertical
        trackCounterStackView.distribution = .equalSpacing
        
        let tracksCountLabel = viewFactory.trackLabel(Constants.tracksCountLabelFontSize, .medium, .lightGray, Constants.tracksCountLabelNumberOfLines)
        let selectedTracksCountLabel = viewFactory.trackLabel(Constants.selectedTracksCountLabelFontSize, .medium, .lightGray, Constants.selectedTracksCountLabelNumberOfLines)
        
        self.tracksCountLabel = tracksCountLabel
        self.selectedTracksCountLabel = selectedTracksCountLabel
        
        trackCounterStackView.addArrangedSubview(tracksCountLabel)
        trackCounterStackView.addArrangedSubview(selectedTracksCountLabel)
        
        trackCounterStackView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, Constants.trackCounterStackViewBottom)
        trackCounterStackView.pinHorizontal(to: view, Constants.trackCounterStackViewOffset)
    }
    
    // MARK: - Private utility methods
    private func setSelectedTracksCount(_ selectedTracksCount: String) {
        selectedTracksCountLabel?.text = "Выбрано: \(selectedTracksCount)"
    }
    
    private func audioFile(for indexPath: IndexPath) -> AudioFile {
        switch Section(rawValue: indexPath.section) {
        case .cloud:
            return cloudFiles[indexPath.row]
        case .downloaded:
            return downloadedFiles[indexPath.row]
        case .none:
            return [] as! AudioFile
        }
    }
}

// MARK: - UISearchBarDelegate
extension AddToPlaylistViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        interactor.searchAudioFiles(AddToPlaylistModel.Search.Request(query: searchText))
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        interactor.searchAudioFiles(AddToPlaylistModel.Search.Request(query: ""))
    }
}

// MARK: - UITableViewDataSource
extension AddToPlaylistViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .cloud:
            return cloudFiles.count
        case .downloaded:
            return downloadedFiles.count
        default:
            return Int()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FetchedAudioCell.reuseId,
            for: indexPath
        ) as! FetchedAudioCell
        
        let audioFile = audioFile(for: indexPath)
        let isSelected = interactor.selectedTracks.contains(audioFile.playbackUrl)
        
        cell.delegate = self
        cell.configure(isEditingMode: true, img: audioFile.trackImg, isSelected: isSelected, audioName: audioFile.name, artistName: audioFile.artistName, duration: audioFile.durationInSeconds, audioFile: audioFile)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .cloud where cloudFiles.isEmpty:
            return nil
        case .downloaded where downloadedFiles.isEmpty:
            return nil
        default: return Section(rawValue: section)?.title
        }
    }
}

// MARK: - UITableViewDelegate
extension AddToPlaylistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.audioTableRowHeight
    }
}

// MARK: - FetchedAudioCellDelegate
extension AddToPlaylistViewController: FetchedAudioCellDelegate {
    func didTapCheckBox(in cell: FetchedAudioCell) {
        guard let indexPath = audioTable.indexPath(for: cell), let audioFile = cell.audioFile else { return }
                
        interactor.toggleTrackSelection(AddToPlaylistModel.TrackSelection.Request(audioFile: audioFile, indexPath: indexPath))
    }
}
