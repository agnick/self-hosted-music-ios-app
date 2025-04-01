import UIKit

final class PlaylistsViewController: UIViewController {
    // MARK: - Enums
    enum Constants {
        // titleLabel settings.
        static let titleLabelFontSize: CGFloat = 32
        static let titleLabelLeading: CGFloat = 20
        
        // searchBar settings.
        static let searchBarTop: CGFloat = 20
        static let searchBarLeading: CGFloat = 20
        static let searchBarTrailing: CGFloat = 20
        static let searchBarHeight: CGFloat = 35
        static let searchBarTextFieldMargin: CGFloat = 0
        
        // createNewPlaylistButton settings
        static let createNewPlaylistButtonFontSize: CGFloat = 16
        static let createNewPlaylistButtonTop: CGFloat = 10
        static let createNewPlaylistButtonOffset: CGFloat = 20
        static let createNewPlaylistButtonImageSize: CGFloat = 60
        static let createNewPlaylistButtonContentSpacing: CGFloat = 15
        static let createNewPlaylistButtonContentOffset: CGFloat = 10
        static let createNewPlaylistButtonContentLeading: CGFloat = 15
        static let createNewPlaylistButtonCornerRadius: CGFloat = 10
        
        
        // playlistsTable settings.
        static let playlistsTableTop: CGFloat = 10
        static let playlistsTableLeading: CGFloat = 20
        static let playlistsTableTrailing: CGFloat = 20
        static let playlistsTableBottom: CGFloat = 10
        static let playlistsTableRowHeight: CGFloat = 90
    }
    
    // MARK: - Variables
    private let interactor: (PlaylistsBusinessLogic & PlaylistsDataStore)
    
    /* UI components */
    // Labels.
    private let titleLabel: UILabel = UILabel()
    
    // Buttons.
    private var sortButton: UIBarButtonItem?
    private var editButton: UIBarButtonItem?
    private var deleteButton: UIBarButtonItem?
    private let createNewPlaylistButton: UIButton = UIButton(type: .system)
    
    // Other components.
    private let searchBar: UISearchBar = UISearchBar(frame: .zero)
    private let playlistsTable: UITableView = UITableView(frame: .zero)
    
    // MARK: - Lifecycle
    init(interactor: (PlaylistsBusinessLogic & PlaylistsDataStore)) {
        self.interactor = interactor
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
        interactor.fetchAllPlaylists()
    }
    
    // MARK: - Tab bar actions
    @objc private func sortButtonTapped() {
        // Showing sort action sheet.
        interactor.loadSortOptions()
    }

    @objc private func editButtonTapped() {
        interactor.loadEdit()
    }
    
    // MARK: - New playlist creation actions
    @objc private func createNewPlaylistButtonTapped() {
        interactor.createPlaylist()
    }
    
    // MARK: - Playlists edit actions
    @objc private func deleteSelectedPlaylists() {
        let actions = [
            UIAlertAction(title: "Отмена", style: .default),
            UIAlertAction(title: "Удалить", style: .default) { [weak self] _ in
                guard
                    let self = self
                else {
                    return
                }
                
                self.interactor.deleteSelectedPlaylists()
            }
        ]
        
        presentAlert(title: "Вы уверены, что хотите удалить выбранные плейлисты?", message: "Это действие нельзя отменить", actions: actions)
    }
    
    // MARK: - Public methods
    func displayAllPlaylists() {
        playlistsTable.reloadData()
    }
    
    func displaySortOptions(_ viewModel: PlaylistsModel.SortOptions.ViewModel) {
        let alert = UIAlertController(title: "Выберите тип сортировки", message: nil, preferredStyle: .actionSheet)
        
        let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor(color: .primary)]
        let attributedTitle = NSAttributedString(string: "Выберите тип сортировки", attributes: titleAttributes)
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        
        for option in viewModel.sortOptions {
            let action = UIAlertAction(title: option.title, style: option.isCancel ? .cancel : .default) { _ in
                if let request = option.request {
                    self.interactor.sortPlaylists(request)
                }
            }
            
            action.setValue(UIColor(color: .primary), forKey: "titleTextColor")
            alert.addAction(action)
        }
        
        present(alert, animated: true)
    }
    
    func displayTrackSelection(_ viewModel: PlaylistsModel.TrackSelection.ViewModel) {
        let indexPath = IndexPath(row: viewModel.index, section: 0)
        playlistsTable.reloadRows(at: [indexPath], with: .automatic)
        
        deleteButton?.isEnabled = viewModel.isSelected
    }
    
    func displayEdit(_ viewModel: PlaylistsModel.Edit.ViewModel) {
        // Reload the table to reflect changes in UI.
        playlistsTable.reloadData()
        
        // Update UI elements based on the editing mode state.
        updateEditingModeUI(viewModel.isEditingMode)
    }
    
    func displayError(_ viewModel: PlaylistsModel.Error.ViewModel) {
        let actions = [UIAlertAction(title: "OK", style: .default)]
        
        self.presentAlert(title: "Ошибка", message: viewModel.errorDescription, actions: actions)
    }
    
    // MARK: - Private methods for UI configuring
    private func configureUI() {
        view.backgroundColor = UIColor(color: .background)
        
        configureNavigationBar()
        configureTitleLabel()
        configureSearchBar()
        configureCreateNewPlaylistButton()
        configurePlaylistsTable()
    }
    
    private func configureNavigationBar() {
        let sortButton = UIBarButtonItem(title: "Сортировать", style: .plain, target: self, action: #selector(sortButtonTapped))
        
        let editButton = UIBarButtonItem(title: "Изменить", style: .plain, target: self, action: #selector(editButtonTapped))
        
        self.sortButton = sortButton
        self.editButton = editButton
        
        navigationItem.leftBarButtonItem = sortButton
        navigationItem.rightBarButtonItem = editButton
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
        titleLabel.text = "Плейлисты"
        
        // Set constraints to position the title label.
        titleLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.pinLeft(to: view, Constants.titleLabelLeading)
    }
    
    private func configureSearchBar() {
        view.addSubview(searchBar)
        
        searchBar.placeholder = "Искать в плейлистах"
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
        
        searchBar.pinTop(to: titleLabel.bottomAnchor, Constants.searchBarTop)
        searchBar.pinLeft(to: view, Constants.searchBarLeading)
        searchBar.pinRight(to: view, Constants.searchBarTrailing)
        searchBar.setHeight(Constants.searchBarHeight)
    }
    
    private func configureCreateNewPlaylistButton() {
        view.addSubview(createNewPlaylistButton)
        
        let imageView = UIImageView(image: UIImage(image: .icCreateNewPlaylist))
        imageView.contentMode = .scaleAspectFit
        imageView.setWidth(Constants.createNewPlaylistButtonImageSize)
        imageView.setHeight(Constants.createNewPlaylistButtonImageSize)
        
        let label = UILabel()
        label.text = "Создать новый плейлист"
        label.font = .systemFont(ofSize: Constants.createNewPlaylistButtonFontSize, weight: .semibold)
        label.textColor = UIColor(color: .primary)
        
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .horizontal
        stack.isUserInteractionEnabled = false
        stack.spacing = Constants.createNewPlaylistButtonContentSpacing
        stack.alignment = .center
        
        createNewPlaylistButton.addSubview(stack)
        
        createNewPlaylistButton.backgroundColor = UIColor(color: .buttonColor)
        createNewPlaylistButton.layer.cornerRadius = Constants.createNewPlaylistButtonCornerRadius
        createNewPlaylistButton.clipsToBounds = true
        
        stack.pinVertical(to: createNewPlaylistButton, Constants.createNewPlaylistButtonContentOffset)
        stack.pinLeft(to: createNewPlaylistButton.leadingAnchor, Constants.createNewPlaylistButtonContentLeading)
        
        createNewPlaylistButton.addTarget(self, action: #selector(createNewPlaylistButtonTapped), for: .touchUpInside)

        createNewPlaylistButton.pinTop(to: searchBar.bottomAnchor, Constants.createNewPlaylistButtonTop)
        createNewPlaylistButton.pinHorizontal(to: view, Constants.createNewPlaylistButtonOffset)
    }

    private func configurePlaylistsTable() {
        view.addSubview(playlistsTable)
        
        playlistsTable.backgroundColor = .clear
        playlistsTable.separatorStyle = .none
        
        // Set the data source and delegate for the tableView view.
        playlistsTable.dataSource = self
        playlistsTable.delegate = self
        
        // Register the cell class for reuse.
        playlistsTable
            .register(
                PlaylistCell.self,
                forCellReuseIdentifier: PlaylistCell.reuseId
            )
        
        playlistsTable.isScrollEnabled = true
        playlistsTable.alwaysBounceVertical = true
        playlistsTable.contentInset = .zero
        playlistsTable.contentInsetAdjustmentBehavior = .never
        
        // Set constraints to position the table view.
        playlistsTable
            .pinTop(
                to: createNewPlaylistButton.bottomAnchor, Constants.playlistsTableTop)
        playlistsTable
            .pinLeft(
                to: view,
                Constants.playlistsTableLeading
            )
        playlistsTable
            .pinRight(
                to: view,
                Constants.playlistsTableTrailing
            )
        playlistsTable
            .pinBottom(
                to: view.safeAreaLayoutGuide.bottomAnchor,
                Constants.playlistsTableBottom
            )
    }
    
    // MARK: - Private methods to update UI on edit
    private func updateEditingModeUI(_ isEditing: Bool) {
        if isEditing {
            deleteButton = UIBarButtonItem(title: "Удалить", style: .plain, target: self, action: #selector(deleteSelectedPlaylists))
            
            navigationItem.leftBarButtonItems = [deleteButton].compactMap { $0 }
            
            deleteButton?.isEnabled = !isEditing
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(editButtonTapped))
        } else {
            navigationItem.leftBarButtonItems = nil
            navigationItem.leftBarButtonItem = sortButton
            navigationItem.rightBarButtonItem = editButton
            
            deleteButton = nil
        }
    }
}

// MARK: - UISearchBarDelegate
extension PlaylistsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        interactor.searchPlaylists(PlaylistsModel.Search.Request(query: searchText))
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        interactor.searchPlaylists(PlaylistsModel.Search.Request(query: ""))
    }
}

// MARK: - UITableViewDataSource
extension PlaylistsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interactor.playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: PlaylistCell.reuseId,
            for: indexPath
        ) as! PlaylistCell
        cell.delegate = self
        
        guard
            indexPath.row < interactor.playlists.count
        else {
            return cell
        }
        
        let playlistId = interactor.playlists[indexPath.row].id
        let isSelected = interactor.selectedPlaylistIDs.contains(playlistId)
        
        let playlist = interactor.playlists[indexPath.row]
        cell.configure(playlist.image, playlist.title, isEditingMode: interactor.isEditingModeEnabled, isSelected: isSelected)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PlaylistsViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        interactor.loadPlaylistScreen(PlaylistsModel.LoadPlaylist.Request(index: indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.playlistsTableRowHeight
    }
}

// MARK: - FetchedAudioCellDelegate
extension PlaylistsViewController: PlaylistCellDelegate {
    func didTapCheckBox(in cell: PlaylistCell) {
        guard let indexPath = playlistsTable.indexPath(for: cell) else { return }
        
        interactor.togglePlaylistsSelection(PlaylistsModel.TrackSelection.Request(index: indexPath.row))
    }
}
