//
//  MyMusicViewController.swift
//  MusicApp
//
//  Created by Никита Агафонов on 17.01.2025.
//

import UIKit
import AVKit
import AVFoundation

final class MyMusicViewController: UIViewController {
    // MARK: - Enums
    enum Constants {
        // titleLabel settings.
        static let titleLabelFontSize: CGFloat = 32
        static let titleLabelTop: CGFloat = 100
        static let titleLabelLeading: CGFloat = 20
        
        // segmentedControl settings.
        static let segmentedControlTop: CGFloat = 20
        static let segmentedControlLeading: CGFloat = 20
        static let defaultSegment: Int = 0
        static let secondarySegment: Int = 1
        
        // searchBar settings.
        static let searchBarTop: CGFloat = 20
        static let searchBarLeading: CGFloat = 20
        static let searchBarTrailing: CGFloat = 20
        static let searchBarHeight: CGFloat = 35
        static let searchBarTextFieldMargin: CGFloat = 0
        
        // actionButton settings.
        static let actionButtonImagePadding: CGFloat = 5
        static let actionButtonFontSize: CGFloat = 16
        
        // pickAllButton settings.
        static let pickAllButtonOffsetX: CGFloat = 20
        static let pickAllButtonTop: CGFloat = 10
        static let pickAllButtonHeight: CGFloat = 45
        
        // buttonStackView settings.
        static let buttonStackViewSpacing: CGFloat = 15
        static let buttonStackViewTop: CGFloat = 10
        static let buttonStackViewLeading: CGFloat = 20
        static let buttonStackViewTrailing: CGFloat = 20
        static let buttonStackViewHeight: CGFloat = 45
        
        // audioTable settings.
        static let audioTableViewTop: CGFloat = 10
        static let audioTableLeading: CGFloat = 20
        static let audioTableTrailing: CGFloat = 20
        static let audioTableBottom: CGFloat = 10
        static let audioTableRowHeight: CGFloat = 90
        
        // activityIndicator settings.
        static let activityIndicatorTop: CGFloat = 50
    }
    
    // MARK: - Variables
    // MyMusic screen interactor, it contains all bussiness logic.
    private var interactor: (MyMusicBusinessLogic & MyMusicDataStore)
    // View factory for MyMusicViewController.
    private let viewFactory: MyMusicViewFactory
        
    /* UI components */
    // Buttons.
    private var sortButton: UIBarButtonItem?
    private var editButton: UIBarButtonItem?
    private var playButton: UIButton?
    private var shuffleButton: UIButton?
    private var pickAllButton: UIButton?
    // Labels.
    private let titleLabel: UILabel = UILabel()
    // Other components.
    private let segmentedControl: UISegmentedControl = UISegmentedControl()
    private let searchBar: UISearchBar = UISearchBar(frame: .zero)
    private let buttonStackView: UIStackView = UIStackView()
    private let audioTable: UITableView = UITableView(frame: .zero)
    private let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(
        style: .medium
    )
    
    // MARK: - Lifecycle
    init(interactor: (MyMusicBusinessLogic & MyMusicDataStore), viewFactory: MyMusicViewFactory) {
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
        
        // Load initial data about the connected cloud service.
        interactor.loadStart(MyMusicModel.Start.Request())
        
        // Fetch and update audio files for the first segment (default selection).
        interactor.updateAudioFiles(MyMusicModel.UpdateAudio.Request(selectedSegmentIndex: Constants.defaultSegment))
    }
    
    // MARK: - Tab bar actions
    @objc private func sortButtonTapped() {
        // Showing sort action sheet.
        interactor.loadSortOptions()
    }

    @objc private func editButtonTapped() {
        interactor.loadEdit(MyMusicModel.Edit.Request())
    }
    
    @objc private func deleteSelectedTracks() {
        interactor.deleteTracks(MyMusicModel.Delete.Request(selectedSegmentIndex: segmentedControl.selectedSegmentIndex))
    }
    
    @objc private func addTrackToPlaylist() {
        // TODO: - add to playlist
    }
    
    // MARK: - Segment action
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        interactor.updateAudioFiles(MyMusicModel.UpdateAudio.Request(selectedSegmentIndex: segmentedControl.selectedSegmentIndex))
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
    
    @objc private func pickAllButtonPressed() {
        interactor.pickAll(MyMusicModel.PickTracks.Request())
    }
    
    
    // MARK: - Public methods
    func displayStart(_ viewModel: MyMusicModel.Start.ViewModel) {
        setSegmets(cloudServiceName: viewModel.cloudServiceName)
    }
    
    func displayAudioFiles(
        _ viewModel: MyMusicModel.FetchedFiles.ViewModel
    ) {
        activityIndicator.stopAnimating()
        audioTable.reloadData()
        
        activateButtons(viewModel.buttonsState)
        
        // TODO: set tracks count
    }
    
    func displayPreLoading(_ viewModel: MyMusicModel.PreLoading.ViewModel) {
        // Block UI interactions while loading new audio files.
        activateButtons(viewModel.buttonsState)
        
        // Reload the table view to reflect the cleared state.
        audioTable.reloadData()
        
        // Start the activity indicator to show loading progress.
        activityIndicator.startAnimating()
    }
    
    func displayEdit(_ viewModel: MyMusicModel.Edit.ViewModel) {
        // Enable or disable table view editing based on the new editing mode state.
        audioTable.setEditing(viewModel.isEditingMode, animated: true)
        // Reload the table to reflect changes in UI.
        audioTable.reloadData()
        
        // Disable segmented control while in editing mode to prevent switching lists.
        segmentedControl.isEnabled = !viewModel.isEditingMode
        
        // Update UI elements based on the editing mode state.
        updateEditingModeUI(viewModel.isEditingMode)
    }
    
    func displayPickAll(_ viewModel: MyMusicModel.PickTracks.ViewModel) {
        pickAllButton?.setTitle(viewModel.buttonTitle, for: .normal)
        
        audioTable.reloadData()
    }
    
    func displaySortOptions(_ viewModel: MyMusicModel.SortOptions.ViewModel) {
        let alert = UIAlertController(title: "Выберите тип сортировки", message: nil, preferredStyle: .actionSheet)
        
        let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor(color: .primary)]
        let attributedTitle = NSAttributedString(string: "Выберите тип сортировки", attributes: titleAttributes)
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        
        for option in viewModel.sortOptions {
            let action = UIAlertAction(title: option.title, style: option.isCancel ? .cancel : .default) { _ in
                if let request = option.request {
                    self.interactor.sortAudioFiles(request)
                }
            }
            
            action.setValue(UIColor(color: .primary), forKey: "titleTextColor")
            alert.addAction(action)
        }
        
        present(alert, animated: true)
    }
    
    func displayError(
        _ viewModel: MyMusicModel.Error.ViewModel
    ) {
        let actions = [UIAlertAction(title: "OK", style: .default)]
        
        self.presentAlert(
            title: "Ошибка",
            message: viewModel.errorDescription,
            actions: actions
        )
    }
    
    func displayCellData(_ viewModel: MyMusicModel.CellData.ViewModel) {
        guard let cell = audioTable.cellForRow(at: IndexPath(row: viewModel.index, section: 0)) as? FetchedAudioCell else { return }
        
        cell.configure(isEditingMode: viewModel.isEditingMode, isSelected: viewModel.isSelected, audioName: viewModel.name, artistName: viewModel.artistName, duration: viewModel.durationInSeconds)
    }
    
    func displayTrackSelection(_ viewModel: MyMusicModel.TrackSelection.ViewModel) {
        let indexPath = IndexPath(row: viewModel.index, section: 0)
        audioTable.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Private methods for UI configuring
    private func configureUI() {
        view.backgroundColor = UIColor(color: .background)
        
        configureNavigationBar()
        configureTitleLabel()
        configureSegmentedControl()
        configureSearchBar()
        configurePickAllBurron()
        configureButtonStack()
        configureAudioTable()
        configureActivityIndicator()
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
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
        titleLabel.text = "Моя музыка"
        
        // Set constraints to position the title label.
        titleLabel.pinTop(to: view, Constants.titleLabelTop)
        titleLabel.pinLeft(to: view, Constants.titleLabelLeading)
    }
    
    private func configureSearchBar() {
        view.addSubview(searchBar)
        
        searchBar.placeholder = "Искать в музыке"
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
        
        searchBar.pinTop(to: segmentedControl.bottomAnchor, Constants.searchBarTop)
        searchBar.pinLeft(to: view, Constants.searchBarLeading)
        searchBar.pinRight(to: view, Constants.searchBarTrailing)
        searchBar.setHeight(Constants.searchBarHeight)
    }
    
    private func configureSegmentedControl() {
        view.addSubview(segmentedControl)
        
        segmentedControl.selectedSegmentTintColor = UIColor(color: .secondary)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor(color: .primary)], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
        segmentedControl.pinTop(to: titleLabel.bottomAnchor, Constants.segmentedControlTop)
        segmentedControl.pinLeft(to: view, Constants.segmentedControlLeading)
    }
    
    private func configurePickAllBurron() {
        let pickAllButton: UIButton = viewFactory.audioActionButton(with: UIImage(image: .icCheck), title: "Выбрать все", imagePadding: Constants.actionButtonImagePadding, fontSize: Constants.actionButtonFontSize)
        
        view.addSubview(pickAllButton)
        
        pickAllButton.addTarget(self, action: #selector(pickAllButtonPressed), for: .touchUpInside)
        
        pickAllButton.isHidden = true
        
        pickAllButton.pinHorizontal(to: view, Constants.pickAllButtonOffsetX)
        pickAllButton.pinTop(to: searchBar.bottomAnchor, Constants.pickAllButtonTop)
        pickAllButton.setHeight(Constants.pickAllButtonHeight)
        
        self.pickAllButton = pickAllButton
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
        
        buttonStackView.pinLeft(to: view, Constants.buttonStackViewLeading)
        buttonStackView.pinRight(to: view, Constants.buttonStackViewTrailing)
        buttonStackView.pinTop(to: searchBar.bottomAnchor, Constants.buttonStackViewTop)
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
        
        // Set constraints to position the table view.
        audioTable
            .pinTop(
                to: buttonStackView.bottomAnchor, Constants.audioTableViewTop)
        audioTable
            .pinLeft(
                to: view,
                Constants.audioTableLeading
            )
        audioTable
            .pinRight(
                to: view,
                Constants.audioTableTrailing
            )
        audioTable
            .pinBottom(
                to: view.safeAreaLayoutGuide.bottomAnchor,
                Constants.audioTableBottom
            )
    }
    
    private func configureActivityIndicator() {
        view.addSubview(activityIndicator)
        
        // Set indicator settings.
        activityIndicator.color = UIColor(color: .primary)
        activityIndicator.hidesWhenStopped = true
        
        // Set constraints to position the indicator.
        activityIndicator.pinTop(to: buttonStackView.bottomAnchor, Constants.activityIndicatorTop)
        activityIndicator.pinCenterX(to: view)
    }
    
    // MARK: - Private method to configure segment
    private func setSegmets(cloudServiceName: String) {
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: cloudServiceName, at: Constants.defaultSegment, animated: false)
        segmentedControl.insertSegment(withTitle: "Скаченные", at: Constants.secondarySegment, animated: false)
        
        segmentedControl.selectedSegmentIndex = Constants.defaultSegment
    }
    
    // MARK: - Private method to control UI enabling
    private func activateButtons(_ state: Bool) {
        sortButton?.isEnabled = state
        editButton?.isEnabled = state
        
        playButton?.isEnabled = state
        shuffleButton?.isEnabled = state
    }
    
    // MARK: - Private methods to update UI on edit
    private func updateEditingModeUI(_ isEditing: Bool) {
        playButton?.isHidden = isEditing
        shuffleButton?.isHidden = isEditing
        pickAllButton?.isHidden = !isEditing
        buttonStackView.isHidden = isEditing
        
        if isEditing {
            let deleteButton = UIBarButtonItem(title: "Удалить", style: .plain, target: self, action: #selector(deleteSelectedTracks))
            let addButton = UIBarButtonItem(title: "Добавить", style: .plain, target: self, action: #selector(addTrackToPlaylist))
            
            navigationItem.leftBarButtonItems = [deleteButton, addButton]
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(editButtonTapped))
        } else {
            navigationItem.leftBarButtonItems = nil
            navigationItem.leftBarButtonItem = sortButton
            navigationItem.rightBarButtonItem = editButton
        }
    }
}

// MARK: - UITableViewDataSource
extension MyMusicViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interactor.currentAudioFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FetchedAudioCell.reuseId,
            for: indexPath
        ) as! FetchedAudioCell
        cell.delegate = self
        
        interactor.getCellData(MyMusicModel.CellData.Request(index: indexPath.row))
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MyMusicViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        interactor.playSelectedTrack(MyMusicModel.Play.Request(index: indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.audioTableRowHeight
    }
}

// MARK: - UISearchBarDelegate
extension MyMusicViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        interactor.searchAudioFiles(MyMusicModel.Search.Request(query: searchText))
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        interactor.searchAudioFiles(MyMusicModel.Search.Request(query: ""))
    }
}

// MARK: - FetchedAudioCellDelegate
extension MyMusicViewController: FetchedAudioCellDelegate {
    func didTapCheckBox(in cell: FetchedAudioCell) {
        guard let indexPath = audioTable.indexPath(for: cell) else { return }
                
        interactor.toggleTrackSelection(MyMusicModel.TrackSelection.Request(index: indexPath.row))
    }
}
