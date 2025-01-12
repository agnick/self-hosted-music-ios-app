//
//  AudioFilesOverviewScreenViewController.swift
//  MusicApp
//
//  Created by Никита Агафонов on 07.01.2025.
//

import UIKit

final class AudioFilesOverviewScreenViewController: UIViewController {
    // MARK: - Enums
    enum AudioFilesOverviewScreenConstants {
        // cloudServiceName settings.
        static let cloudServiceNameFontSize: CGFloat = 32
        static let cloudServiceNameTop: CGFloat = 100
        static let cloudServiceNameLeading: CGFloat = 20
        
        // guideLabel settings.
        static let guideLabelFontSize: CGFloat = 16
        static let guideLabelTop: CGFloat = 10
        static let guideLabelLeading: CGFloat = 20
        static let guideLabelTrailing: CGFloat = 20
        static let guideLabelLines: Int = 0
        
        // audioFilesTable settings.
        static let audioFilesTableViewTop: CGFloat = 20
        static let audioFilesTableLeading: CGFloat = 20
        static let audioFilesTableTrailing: CGFloat = 20
        static let audioFilesTableBottom: CGFloat = 10
        static let audioFilesTableRowHeight: CGFloat = 90
        
        // audioFilesCount settings.
        static let audioFilesCountFontSize: CGFloat = 12
        static let audioFilesCountBottom: CGFloat = 20
        static let audioFilesCountLeading: CGFloat = 20
    }
    
    // MARK: - Variables
    private let interactor: AudioFilesOverviewScreenBusinessLogic
    
    // UI components
    private let cloudServiceName: UILabel = UILabel()
    private let guideLabel: UILabel = UILabel()
    private let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    private let audioFilesTable: UITableView = UITableView(frame: .zero)
    private let audioFilesCount: UILabel = UILabel()
    
    // MARK: - Lifecycle
    init(interactor: AudioFilesOverviewScreenBusinessLogic) {
        self.interactor = interactor
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(parameters:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Импорт", style: .plain, target: nil, action: nil)

        configureUI()
        
        interactor.loadStart(AudioFilesOverviewScreenModel.Start.Request())
        activityIndicator.startAnimating()
        interactor.fetchAudioFiles(AudioFilesOverviewScreenModel.FetchedFiles.Request())
    }
    
    // MARK: - Actions
    @objc private func backBtnTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Public methods
    func displayAudioFiles(_ viewModel: AudioFilesOverviewScreenModel.FetchedFiles.ViewModel) {
        activityIndicator.stopAnimating()
        audioFilesTable.reloadData()
        audioFilesCount.text = "Всего треков: \(viewModel.audioFilesCount)"
    }
    
    func displayStart(_ viewModel: AudioFilesOverviewScreenModel.Start.ViewModel) {
        cloudServiceName.text = viewModel.serviceName
    }
    
    func displayError(_ viewModel: AudioFilesOverviewScreenModel.Error.ViewModel) {
        print("Error: \(viewModel.errorDescription)")
    }
    
    // MARK: - Private methods
    private func configureUI() {
        // Set the background color to the default one from the assets.
        view.backgroundColor = UIColor(named: "Background")
        
        configureCloudServiceName()
        configureGuideLabel()
        configureAudioFilesCount()
        configureAudioFilesTable()
        configureActivityIndicator()
    }
    
    private func configureCloudServiceName() {
        view.addSubview(cloudServiceName)
        
        // Setting the font and text color.
        cloudServiceName.font =
            .systemFont(
                ofSize: AudioFilesOverviewScreenConstants.cloudServiceNameFontSize,
                weight: .bold
            )
        cloudServiceName.textColor = .black
        
        cloudServiceName.pinTop(to: view, AudioFilesOverviewScreenConstants.cloudServiceNameTop)
        cloudServiceName.pinLeft(to: view, AudioFilesOverviewScreenConstants.cloudServiceNameLeading)
    }
    
    private func configureGuideLabel() {
        view.addSubview(guideLabel)
        
        // Setting the font and text color.
        guideLabel.font =
            .systemFont(
                ofSize: AudioFilesOverviewScreenConstants.guideLabelFontSize,
                weight: .medium
            )
        guideLabel.textColor = UIColor(named: "AccentColor")
        guideLabel.text = "Все треки из вашего хранилища уже доступны во вкладке \"Моя Музыка\"."
        // Allow unlimited lines.
        guideLabel.numberOfLines = AudioFilesOverviewScreenConstants.guideLabelLines
        guideLabel.textAlignment = .justified
        
        guideLabel.pinTop(to: cloudServiceName.bottomAnchor, AudioFilesOverviewScreenConstants.guideLabelTop)
        guideLabel.pinLeft(to: view, AudioFilesOverviewScreenConstants.guideLabelLeading)
        guideLabel.pinRight(to: view, AudioFilesOverviewScreenConstants.guideLabelTrailing)
    }
    
    private func configureAudioFilesCount() {
        view.addSubview(audioFilesCount)
        
        // Setting the font and text color.
        audioFilesCount.font =
            .systemFont(
                ofSize: AudioFilesOverviewScreenConstants.audioFilesCountFontSize,
                weight: .medium
            )
        audioFilesCount.textColor = .systemGray
        
        audioFilesCount.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, AudioFilesOverviewScreenConstants.audioFilesCountBottom)
        audioFilesCount.pinLeft(to: view, AudioFilesOverviewScreenConstants.audioFilesCountLeading)
    }
    
    private func configureAudioFilesTable() {
        view.addSubview(audioFilesTable)
        
        audioFilesTable.backgroundColor = .clear
        audioFilesTable.separatorStyle = .none
        
        // Set the data source and delegate for the tableView view.
        audioFilesTable.dataSource = self
        audioFilesTable.delegate = self
        
        // Register the cell class for reuse.
        audioFilesTable
            .register(
                AudioFilesCell.self,
                forCellReuseIdentifier: AudioFilesCell.reuseId
            )
        
        audioFilesTable.isScrollEnabled = true
        audioFilesTable.alwaysBounceVertical = true
        audioFilesTable.contentInset = .zero
        audioFilesTable.contentInsetAdjustmentBehavior = .never
        
        // Set constraints to position the table view.
        audioFilesTable
            .pinTop(
                to: guideLabel.bottomAnchor            )
        audioFilesTable
            .pinLeft(
                to: view,
                AudioFilesOverviewScreenConstants.audioFilesTableLeading
            )
        audioFilesTable
            .pinRight(
                to: view,
                AudioFilesOverviewScreenConstants.audioFilesTableTrailing
            )
        audioFilesTable
            .pinBottom(
                to: audioFilesCount.topAnchor,
                AudioFilesOverviewScreenConstants.audioFilesTableBottom
            )
    }
    
    private func configureActivityIndicator() {
        view.addSubview(activityIndicator)
        
        // Set indicator settings.
        activityIndicator.color = UIColor(named: "AccentColor")
        activityIndicator.hidesWhenStopped = true
        
        // Set constraints to position the indicator.
        activityIndicator.pinCenter(to: view)
    }
}

// MARK: - UITableViewDataSource
extension AudioFilesOverviewScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interactor.getAudioFiles().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: AudioFilesCell.reuseId,
            for: indexPath
        ) as! AudioFilesCell
        
        let audioName = interactor.getAudioFiles()[indexPath.row].name
        let audioSize = interactor.getAudioFiles()[indexPath.row].sizeInMB
        
        cell.configure(audioName, audioSize)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AudioFilesOverviewScreenViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AudioFilesOverviewScreenConstants.audioFilesTableRowHeight
    }
}

