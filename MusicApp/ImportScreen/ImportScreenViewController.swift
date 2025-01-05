//
//  ImportScreenViewController.swift
//  MusicApp
//
//  Created by Никита Агафонов on 28.12.2024.
//

import UIKit

final class ImportScreenViewController: UIViewController {
    // MARK: - Enums
    enum ImportScreenConstants {
        // TitleLabel settings.
        static let titleLabelFontSize: CGFloat = 32
        static let titleLabelTop: CGFloat = 80
        static let titleLabelLeading: CGFloat = 20
        
        // ImportOptionsTableView settings.
        static let importOptionsTableViewTop: CGFloat = 20
        static let importOptionsTableViewLeading: CGFloat = 20
        static let importOptionsTableViewTrailing: CGFloat = 20
        static let importOptionsTableViewBottom: CGFloat = 20
        static let importOptionsTableRowHeight: CGFloat = 90
        
        // Section label settings
        static let sectionLabelFontSize: CGFloat = 16
    }
    
    // MARK: - Variables
    private let interactor: (ImportScreenBusinessLogic & ImportScreenDataStore)
    
    // UI components
    private let titleLabel: UILabel = UILabel()
    private let importOptionsTableView: UITableView = UITableView(frame: .zero)
    
    // MARK: - Lifecycle
    init(interactor: (ImportScreenBusinessLogic & ImportScreenDataStore)) {
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
    
    // MARK: - Private methods
    private func configureUI() {
        // Set the background color to the default one from the assets.
        view.backgroundColor = UIColor(named: "Background")
        
        configureTitleLable()
        configureImportOptionsTable()
    }
    
    private func configureTitleLable() {
        view.addSubview(titleLabel)
        
        // Setting the font and text color.
        titleLabel.font = 
            .systemFont(
                ofSize: ImportScreenConstants.titleLabelFontSize,
                weight: .bold
            )
        titleLabel.textColor = .black
        titleLabel.text = "Импорт музыки"
        
        titleLabel.pinTop(to: view, ImportScreenConstants.titleLabelTop)
        titleLabel.pinLeft(to: view, ImportScreenConstants.titleLabelLeading)
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
                ImportScreenConstants.importOptionsTableViewLeading
            )
        importOptionsTableView
            .pinRight(
                to: view,
                ImportScreenConstants.importOptionsTableViewTrailing
            )
        importOptionsTableView
            .pinBottom(
                to: view.safeAreaLayoutGuide.bottomAnchor,
                ImportScreenConstants.importOptionsTableViewBottom
            )
    }
}

// MARK: - UITableViewDataSource
extension ImportScreenViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return interactor.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interactor.sections[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImportOptionsCell.reuseId,
            for: indexPath
        ) as! ImportOptionsCell
        
        let item = interactor.sections[indexPath.section].1[indexPath.row]
        cell.configure(UIImage(named: item.1), item.0)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return interactor.sections[section].0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "Background")
        
        let label = UILabel()
        label.text = interactor.sections[section].0
        label.font = 
            .systemFont(
                ofSize: ImportScreenConstants.sectionLabelFontSize,
                weight: .bold
            )
        label.textColor = .black
        
        headerView.addSubview(label)
        
        label.pinLeft(to: headerView)
        label.pinTop(to: headerView)
        
        return headerView
    }
}

// MARK: - UITableViewDelegate
extension ImportScreenViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let selectedSection = interactor.sections[indexPath.section]
        let selectedOption = selectedSection.1[indexPath.row].0
        
        switch selectedOption {
        case "Google drive":
            interactor.handleCloudServiceSelection(service: .googleDrive)
        case "Yandex cloud":
            interactor.handleCloudServiceSelection(service: .yandexCloud)
        case "Dropbox":
            interactor.handleCloudServiceSelection(service: .dropbox)
        case "One Drive":
            interactor.handleCloudServiceSelection(service: .oneDrive)
        case "Локальные файлы":
            interactor.handleLocalFilesSelection()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ImportScreenConstants.importOptionsTableRowHeight
    }
}
