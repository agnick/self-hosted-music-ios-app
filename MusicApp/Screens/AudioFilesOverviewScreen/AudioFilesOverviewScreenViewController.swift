import UIKit

final class AudioFilesOverviewScreenViewController: UIViewController {
    // MARK: - Enums
    enum Constants {
        // cloudServiceName settings.
        static let cloudServiceNameFontSize: CGFloat = 32
        static let cloudServiceNameLeading: CGFloat = 20
        
        // downloadAllBtn settings.
        static let downloadAllBtnFontSize: CGFloat = 16
        static let downloadAllBtnTop: CGFloat = 20
        static let downloadAllBtnLeading: CGFloat = 20
        static let downloadAllBtnTrailing: CGFloat = 20
        static let downloadAllBtnHeight: CGFloat = 45
        static let downloadAllBtnCornerRadius: CGFloat = 10
        static let downloadAllBtnImagePadding: CGFloat = 5
        static let downloadAllBtnDisabledAlpha: CGFloat = 0.5
        static let downloadAllBtnEnabledAlpha: CGFloat = 1
        
        // audioFilesTable settings.
        static let audioFilesTableViewTop: CGFloat = 5
        static let audioFilesTableLeading: CGFloat = 20
        static let audioFilesTableTrailing: CGFloat = 20
        static let audioFilesTableBottom: CGFloat = 10
        static let audioFilesTableRowHeight: CGFloat = 90
        
        // audioFilesCount settings.
        static let audioFilesCountFontSize: CGFloat = 12
        static let audioFilesCountBottom: CGFloat = 20
        static let audioFilesCountLeading: CGFloat = 20
        
        // toastLabel settings.
        static let toastLabelFontSize: CGFloat = 14
    }
    
    // MARK: - Variables
    private let interactor: AudioFilesOverviewScreenBusinessLogic & AudioFilesOverviewScreenDataStore
    
    // UI components
    private let cloudServiceName: UILabel = UILabel()
    private let downloadAllBtn: UIButton = UIButton(type: .system)
    private let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(
        style: .large
    )
    private let audioFilesTable: UITableView = UITableView(frame: .zero)
    private let audioFilesCount: UILabel = UILabel()
    private let toastLabel: UILabel = UILabel()
    
    // MARK: - Lifecycle
    init(interactor: AudioFilesOverviewScreenBusinessLogic & AudioFilesOverviewScreenDataStore) {
        self.interactor = interactor
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(parameters:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        
        interactor.loadStart()
        activityIndicator.startAnimating()
        interactor.fetchAudioFiles()
    }
    
    // MARK: - Actions
    @objc private func backBtnTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func downloadAllTapped() {
        disableDownloadAllBtn()
        interactor.downloadAllAudioFiles()
    }
    
    @objc private func refreshAudioFiles() {
        disableDownloadAllBtn()
        interactor.refreshAudioFiles()
    }
    
    // MARK: - Public methods
    func displayAudioFiles(
        _ viewModel: AudioFilesOverviewScreenModel.FetchedFiles.ViewModel
    ) {
        activityIndicator.stopAnimating()
        audioFilesTable.reloadData()
        audioFilesCount.text = "Всего треков: \(viewModel.audioFilesCount)"
        audioFilesTable.refreshControl?.endRefreshing()
        
        if viewModel.isUserInitiated {
            enableDownloadAllBtn()
        } else {
            disableDownloadAllBtn()
        }
    }
    
    func displayStart(
        _ viewModel: AudioFilesOverviewScreenModel.Start.ViewModel
    ) {
        cloudServiceName.text = viewModel.serviceName
    }
    
    func displayDownloadAudio(
        _ viewModel: AudioFilesOverviewScreenModel.DownloadAudio.ViewModel
    ) {
        audioFilesTable.reloadData()
    }
    
    func displayError(
        _ viewModel: AudioFilesOverviewScreenModel.Error.ViewModel
    ) {
        audioFilesTable.refreshControl?.endRefreshing()
        
        let actions = [UIAlertAction(title: "OK", style: .default)]
        
        self.presentAlert(
            title: "Ошибка",
            message: viewModel.errorDescription,
            actions: actions
        )
    }
    
    // MARK: - Private methods
    private func configureUI() {
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(
            title: "Импорт",
            style: .plain,
            target: nil,
            action: nil
        )
        
        // Set the background color to the default one from the assets.
        view.backgroundColor = UIColor(color: .background)
        
        configureCloudServiceName()
        configureDownloadAllBtn()
        configureAudioFilesCount()
        configureAudioFilesTable()
        configureActivityIndicator()
    }
    
    private func configureCloudServiceName() {
        view.addSubview(cloudServiceName)
        
        // Setting the font and text color.
        cloudServiceName.font =
            .systemFont(
                ofSize: Constants.cloudServiceNameFontSize,
                weight: .bold
            )
        cloudServiceName.textColor = .black
        
        cloudServiceName
            .pinTop(
                to: view.safeAreaLayoutGuide.topAnchor
            )
        cloudServiceName
            .pinLeft(
                to: view,
                Constants.cloudServiceNameLeading
            )
    }
    
    private func configureDownloadAllBtn() {
        view.addSubview(downloadAllBtn)
        
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(image: .icAudioDownload)
        configuration.baseBackgroundColor = UIColor(color: .buttonColor)
        configuration.baseForegroundColor = UIColor(color: .primary)
        configuration.cornerStyle = .medium
        configuration.imagePadding = Constants.downloadAllBtnImagePadding
        configuration.imagePlacement = .leading
        
        var attributedTitle = AttributedString("Скачать все треки")
        attributedTitle.font = 
            .systemFont(
                ofSize: Constants.downloadAllBtnFontSize,
                weight: .semibold
            )
        attributedTitle.foregroundColor = UIColor(
            color: .primary
        )
        configuration.attributedTitle = attributedTitle
            
        downloadAllBtn.configuration = configuration
        
        downloadAllBtn
            .pinTop(
                to: cloudServiceName.bottomAnchor,
                Constants.downloadAllBtnTop
            )
        downloadAllBtn
            .pinLeft(
                to: view,
                Constants.downloadAllBtnLeading
            )
        downloadAllBtn
            .pinRight(
                to: view,
                Constants.downloadAllBtnTrailing
            )
        downloadAllBtn
            .setHeight(Constants.downloadAllBtnHeight)
            
        downloadAllBtn
            .addTarget(
                self,
                action: #selector(downloadAllTapped),
                for: .touchUpInside
            )
    }
    
    private func configureAudioFilesCount() {
        view.addSubview(audioFilesCount)
        
        // Setting the font and text color.
        audioFilesCount.font =
            .systemFont(
                ofSize: Constants.audioFilesCountFontSize,
                weight: .medium
            )
        audioFilesCount.textColor = .systemGray
        
        audioFilesCount
            .pinBottom(
                to: view.safeAreaLayoutGuide.bottomAnchor,
                Constants.audioFilesCountBottom
            )
        audioFilesCount
            .pinLeft(
                to: view,
                Constants.audioFilesCountLeading
            )
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
        
        // Refresh control.
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(color: .primary)
        refreshControl.addTarget(
            self,
            action: #selector(refreshAudioFiles),
            for: .valueChanged
        )
        audioFilesTable.refreshControl = refreshControl
        
        // Set constraints to position the table view.
        audioFilesTable
            .pinTop(
                to: downloadAllBtn.bottomAnchor, Constants.audioFilesTableViewTop)
        audioFilesTable
            .pinLeft(
                to: view,
                Constants.audioFilesTableLeading
            )
        audioFilesTable
            .pinRight(
                to: view,
                Constants.audioFilesTableTrailing
            )
        audioFilesTable
            .pinBottom(
                to: audioFilesCount.topAnchor,
                Constants.audioFilesTableBottom
            )
    }
    
    private func configureActivityIndicator() {
        view.addSubview(activityIndicator)
        
        // Set indicator settings.
        activityIndicator.color = UIColor(color: .primary)
        activityIndicator.hidesWhenStopped = true
        
        // Set constraints to position the indicator.
        activityIndicator.pinCenter(to: view)
    }
    
    // MARK: - Utility methods
    private func disableDownloadAllBtn() {
        downloadAllBtn.isEnabled = false
        downloadAllBtn.alpha = Constants.downloadAllBtnDisabledAlpha
    }
    
    private func enableDownloadAllBtn() {
        downloadAllBtn.isEnabled = true
        downloadAllBtn.alpha = Constants.downloadAllBtnEnabledAlpha
    }
}

// MARK: - UITableViewDataSource
extension AudioFilesOverviewScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interactor.audioFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: AudioFilesCell.reuseId,
            for: indexPath
        ) as! AudioFilesCell
        
        let audioFile = interactor.audioFiles[indexPath.row]
        
        cell.configure(audioFile.trackImg, audioFile.name, audioFile.sizeInMB, downloadState: audioFile.downloadState)
        cell.downloadAction = { [weak self] in
            self?.interactor
                .downloadAudioFiles(
                    AudioFilesOverviewScreenModel.DownloadAudio
                        .Request(audioFile: audioFile, rowIndex: indexPath.row)
                )
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AudioFilesOverviewScreenViewController: UITableViewDelegate {    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.audioFilesTableRowHeight
    }
}

