//
//  AudioImportViewController.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

import UIKit
import UniformTypeIdentifiers

final class AudioImportViewController: UIViewController {
    // MARK: - Enums
    enum Constants {
        // TitleLabel settings.
        static let titleLabelFontSize: CGFloat = 32
        static let titleLabelTop: CGFloat = 100
        static let titleLabelLeading: CGFloat = 20
        
        // ImportOptionsTableView settings.
        static let importOptionsTableViewTop: CGFloat = 20
        static let importOptionsTableViewLeading: CGFloat = 20
        static let importOptionsTableViewTrailing: CGFloat = 20
        static let importOptionsTableViewBottom: CGFloat = 20
        static let importOptionsTableRowHeight: CGFloat = 90
        
        // Section label settings.
        static let sectionLabelFontSize: CGFloat = 16
    }
    
    // MARK: - Variables
    private let interactor: AudioImportBusinessLogic
    private let sections = [
        ("Облачные хранилища", [
            ("Google drive", UIImage(image: .icGoogleDrive)),
            ("Yandex cloud", UIImage(image: .icYandexCloud)),
        ]),
        ("Другие источники", [
            ("Локальные файлы", UIImage(image: .icLocalFiles))
        ])
    ]
    
    // UI components.
    private let titleLabel: UILabel = UILabel()
    private let importOptionsTableView: UITableView = UITableView(frame: .zero)
    
    // MARK: - Lifecycle
    init(interactor: AudioImportBusinessLogic) {
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
    }
    
    // MARK: - Public methods
    func displayFilePicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true)
    }
    
    func displayError(viewModel: AudioImportModel.Error.ViewModel) {
        let actions = [UIAlertAction(title: "OK", style: .default)]
        
        self.presentAlert(title: "Ошибка", message: viewModel.errorDescription, actions: actions)
    }
    
    // MARK: - Private methods
    private func configureUI() {
        // Set the background color to the default one from the assets.
        view.backgroundColor = UIColor(color: .background)
        
        configureTitleLable()
        configureImportOptionsTable()
    }
    
    private func configureTitleLable() {
        view.addSubview(titleLabel)
        
        // Setting the font and text color.
        titleLabel.font = 
            .systemFont(
                ofSize: Constants.titleLabelFontSize,
                weight: .bold
            )
        titleLabel.textColor = .black
        titleLabel.text = "Импорт музыки"
        
        // Set constraints to position the title label.
        titleLabel.pinTop(to: view, Constants.titleLabelTop)
        titleLabel.pinLeft(to: view, Constants.titleLabelLeading)
    }
    
    private func configureImportOptionsTable() {
        view.addSubview(importOptionsTableView)
        
        importOptionsTableView.backgroundColor = .clear
        importOptionsTableView.separatorStyle = .none
        
        // Set the data source and delegate for the tableView view.
        importOptionsTableView.dataSource = self
        importOptionsTableView.delegate = self
        
        // Register the cell class for reuse.
        importOptionsTableView
            .register(
                ImportOptionsCell.self,
                forCellReuseIdentifier: ImportOptionsCell.reuseId
            )
        
        importOptionsTableView.isScrollEnabled = false
        importOptionsTableView.alwaysBounceVertical = true
        importOptionsTableView.contentInset = .zero
        importOptionsTableView.contentInsetAdjustmentBehavior = .never
        
        // Set constraints to position the table view.
        importOptionsTableView
            .pinTop(
                to: titleLabel.bottomAnchor            )
        importOptionsTableView
            .pinLeft(
                to: view,
                Constants.importOptionsTableViewLeading
            )
        importOptionsTableView
            .pinRight(
                to: view,
                Constants.importOptionsTableViewTrailing
            )
        importOptionsTableView
            .pinBottom(
                to: view.safeAreaLayoutGuide.bottomAnchor,
                Constants.importOptionsTableViewBottom
            )
    }
}

// MARK: - UITableViewDataSource
extension AudioImportViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImportOptionsCell.reuseId,
            for: indexPath
        ) as! ImportOptionsCell
        
        // Configure a cell for the given index path.
        let item = sections[indexPath.section].1[indexPath.row]
        cell.configure(item.1, item.0)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Create a header view with a background color.
        let headerView = UIView()
        headerView.backgroundColor = UIColor(color: .background)
        
        // Create a label for the section title and configure its text, font, and color.
        let label = UILabel()
        label.text = sections[section].0
        label.font = 
            .systemFont(
                ofSize: Constants.sectionLabelFontSize,
                weight: .bold
            )
        label.textColor = .black
        
        headerView.addSubview(label)
        
        // Set constraints to position the header view.
        label.pinLeft(to: headerView)
        label.pinTop(to: headerView)
        
        return headerView
    }
}

// MARK: - UITableViewDelegate
extension AudioImportViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        // Identify the selected section and option.
        let selectedSection = sections[indexPath.section]
        let selectedOption = selectedSection.1[indexPath.row].0
        
        // Handle the selection based on the chosen option.
        switch selectedOption {
        case "Google drive":
            interactor.handleCloudServiceSelection(AudioImportModel.CloudServiceSelection.Request(service: .googleDrive))
        case "Yandex cloud":
            interactor.handleCloudServiceSelection(AudioImportModel.CloudServiceSelection.Request(service: .yandexCloud))
        case "Локальные файлы":
            interactor.handleLocalFilesSelection()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.importOptionsTableRowHeight
    }
}

// MARK: - UIDocumentPickerDelegate
extension AudioImportViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard !urls.isEmpty else {
            return
        }
        
        Task {
            await interactor.copySelectedFilesToAppSupportFolder(AudioImportModel.LocalFiles.Request(urls: urls))
        }
    }
}
