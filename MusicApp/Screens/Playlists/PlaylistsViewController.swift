//
//  PlaylistsViewController.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.03.2025.
//

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
        static let createNewPlaylistButtonPadding: CGFloat = 5
        static let createNewPlaylistButtonFontSize: CGFloat = 16
        static let createNewPlaylistButtonTop: CGFloat = 10
        static let createNewPlaylistButtonOffset: CGFloat = 20
        
        // playlistsTable settings.
        static let playlistsTableTop: CGFloat = 10
        static let playlistsTableLeading: CGFloat = 20
        static let playlistsTableTrailing: CGFloat = 20
        static let playlistsTableBottom: CGFloat = 10
        static let playlistsTableRowHeight: CGFloat = 90
    }
    
    // MARK: - Variables
    // Playlists screen interactor, it contains all bussiness logic.
    private let interactor: (PlaylistsBusinessLogic & PlaylistsDataStore)
    
    /* UI components */
    // Labels.
    private let titleLabel: UILabel = UILabel()
    
    // Buttons.
    private var sortButton: UIBarButtonItem?
    private var editButton: UIBarButtonItem?
    private var deleteButton: UIBarButtonItem?
    private var addButton: UIBarButtonItem?
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
    
    // MARK: - Tab bar actions
    @objc private func sortButtonTapped() {
        // Showing sort action sheet.
        
    }

    @objc private func editButtonTapped() {
        
    }
    
    // MARK: - New playlist creation actions
    @objc private func createNewPlaylistButtonTapped() {
        interactor.createPlaylist()
    }
    
    // MARK: - Private methods for UI configuring
    private func configureUI() {
        view.backgroundColor = UIColor(color: .background)
        
        configureNavigationBar()
        configureTitleLabel()
        configureSearchBar()
        configureCreateNewPlaylistButton()
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
        
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(image: .icCreateNewPlaylist)
        configuration.baseBackgroundColor = UIColor(color: .buttonColor)
        configuration.baseForegroundColor = UIColor(color: .primary)
        configuration.cornerStyle = .medium
        configuration.imagePadding = Constants.createNewPlaylistButtonPadding
        configuration.imagePlacement = .leading
        
        let title = "Создать новый плейлист"
        var attributedTitle = AttributedString(title)
        attributedTitle.font =
            .systemFont(
                ofSize: Constants.createNewPlaylistButtonFontSize,
                weight: .semibold
            )
        attributedTitle.foregroundColor = UIColor(
            color: .primary
        )
        configuration.attributedTitle = attributedTitle
            
        createNewPlaylistButton.configuration = configuration
        
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
                FetchedAudioCell.self,
                forCellReuseIdentifier: FetchedAudioCell.reuseId
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
}

// MARK: - UISearchBarDelegate
extension PlaylistsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
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
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PlaylistsViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
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
        
        
        
    }
}
