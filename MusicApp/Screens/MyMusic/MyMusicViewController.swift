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
        // TitleLabel settings.
        static let titleLabelFontSize: CGFloat = 32
        static let titleLabelTop: CGFloat = 100
        static let titleLabelLeading: CGFloat = 20
        
        // segmentedControl settings.
        static let segmentedControlTop: CGFloat = 20
        static let segmentedControlLeading: CGFloat = 20
        
        // searchBar settings.
        static let searchBarTop: CGFloat = 20
        static let searchBarLeading: CGFloat = 20
        static let searchBarTrailing: CGFloat = 20
        static let searchBarHeight: CGFloat = 35
        static let searchBarTextFieldMargin: CGFloat = 0
        
        // ActionButton settings.
        static let actionButtonImagePadding: CGFloat = 5
        static let actionButtonFontSize: CGFloat = 16
        
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
    private var interactor: (MyMusicBusinessLogic & MyMusicDataStore)
    private let viewFactory: MyMusicViewFactory
    
    private var player: AVPlayer?
    
    // UI components.
    private var sortButton: UIBarButtonItem?
    private var editButton: UIBarButtonItem?
    private let titleLabel: UILabel = UILabel()
    private let segmentedControl: UISegmentedControl = UISegmentedControl()
    private let searchBar: UISearchBar = UISearchBar(frame: .zero)
    private var playButton: UIButton?
    private var shuffleButton: UIButton?
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
        
        configureUI()
        interactor.loadStart(MyMusicModel.Start.Request())
        
        blockUI()
        activityIndicator.startAnimating()
        interactor.updateAudioFiles(for: 0)
    }
    
    // MARK: - Actions
    @objc private func sortButtonTapped() {
        showSortActionSheet()
    }

    @objc private func editButtonTapped() {
        
    }
    
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        blockUI()
        interactor.currentAudioFiles.removeAll()
        audioTable.reloadData()
        
        activityIndicator.startAnimating()
        interactor.updateAudioFiles(for: sender.selectedSegmentIndex)
    }
    
    @objc private func playButtonPressed() {
        interactor.playInOrder(MyMusicModel.Play.Request())
    }

    @objc private func playerItemDidFailToPlay(_ notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem, let error = playerItem.error {
            print("AVPlayerItem error: \(error.localizedDescription)")
        }
    }
    
    @objc private func shuffleButtonPressed() {
        
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
        
        activateUI()
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
    
    // MARK: - Private methods
    private func configureUI() {
        view.backgroundColor = UIColor(color: .background)
        
        configureNavigationBar()
        configureTitleLabel()
        configureSegmentedControl()
        configureSearchBar()
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
    
    // MARK: - Helpers
    private func setSegmets(cloudServiceName: String) {
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: cloudServiceName, at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Скаченные", at: 1, animated: false)
        
        segmentedControl.selectedSegmentIndex = 0
    }
    
    private func blockUI() {
        sortButton?.isEnabled = false
        editButton?.isEnabled = false
        
        playButton?.isEnabled = false
        shuffleButton?.isEnabled = false
    }
    
    private func activateUI() {
        sortButton?.isEnabled = true
        editButton?.isEnabled = true
        
        playButton?.isEnabled = true
        shuffleButton?.isEnabled = true
    }
    
    private func showSortActionSheet() {
        let alert = UIAlertController(title: "Выберите тип сортировки", message: nil, preferredStyle: .actionSheet)
        
        let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor(color: .primary)]
        let attributedTitle = NSAttributedString(string: "Выберите тип сортировки", attributes: titleAttributes)
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        
        let actions: [(String, MyMusicModel.Sort.Request?)] = [
            ("Исполнитель (А-я)", .init(sortType: .artistAscending)),
            ("Исполнитель (я-А)", .init(sortType: .artistDescending)),
            ("Название (А-я)", .init(sortType: .titleAscending)),
            ("Название (я-А)", .init(sortType: .titleDescending)),
            ("Длительность (дольше-короче)", .init(sortType: .durationDescending)),
            ("Длительность (короче-дольше)", .init(sortType: .durationAscending)),
            ("Отменить", nil)
        ]
        
        for (title, request) in actions {
            let action = UIAlertAction(title: title, style: request == nil ? .cancel : .default) { _ in
                if let request = request {
                    self.interactor.sortAudioFiles(request)
                }
            }
            action.setValue(UIColor(color: .primary), forKey: "titleTextColor")
            alert.addAction(action)
        }
        
        present(alert, animated: true)
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
        
        let audioFile = interactor.currentAudioFiles[indexPath.row]
        
        cell.configure(audioFile.name, audioFile.artistName, String(audioFile.durationInSeconds))
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MyMusicViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
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
