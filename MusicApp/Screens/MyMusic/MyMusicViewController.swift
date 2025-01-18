//
//  MyMusicViewController.swift
//  MusicApp
//
//  Created by Никита Агафонов on 17.01.2025.
//

import UIKit

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
    private let interactor: MyMusicBusinessLogic
    private let viewFactory: MyMusicViewFactory
    
    // UI components.
    private let titleLabel: UILabel = UILabel()
    private let segmentedControl: UISegmentedControl = UISegmentedControl()
    private let searchBar: UISearchBar = UISearchBar(frame: .zero)
    private let buttonStackView: UIStackView = UIStackView()
    private let audioTable: UITableView = UITableView(frame: .zero)
    private let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(
        style: .medium
    )
    
    // MARK: - Lifecycle
    init(interactor: MyMusicBusinessLogic, viewFactory: MyMusicViewFactory) {
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
        activityIndicator.startAnimating()
        interactor.fetchCloudAudioFiles(MyMusicModel.FetchedFiles.Request())
    }
    
    // MARK: - Actions
    @objc private func sortButtonTapped() {
        
    }

    @objc private func editButtonTapped() {
        
    }
    
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            print("Выбран облачный сервис")
        } else {
            print("Выбраны Скаченные")
        }
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
        
        let textField = searchBar.searchTextField as UITextField
        
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
        let suffleButton: UIButton = viewFactory.audioActionButton(with: UIImage(image: .icShuffle), title: "Перемешать", imagePadding: Constants.actionButtonImagePadding, fontSize: Constants.actionButtonFontSize)
        
        
        buttonStackView.addArrangedSubview(playButton)
        buttonStackView.addArrangedSubview(suffleButton)
        
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
                AudioFilesCell.self,
                forCellReuseIdentifier: AudioFilesCell.reuseId
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
}

// MARK: - UITableViewDataSource
extension MyMusicViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interactor.getAudioFiles().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: AudioFilesCell.reuseId,
            for: indexPath
        ) as! AudioFilesCell
        
        let audioFile = interactor.getAudioFiles()[indexPath.row]
        
        cell.configure(audioFile.name, audioFile.sizeInMB, isDownloading: audioFile.isDownloading)
        
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
