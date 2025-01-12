//
//  SettingsScreenViewController.swift
//  MusicApp
//
//  Created by Никита Агафонов on 12.01.2025.
//

import UIKit

final class SettingsScreenViewController: UIViewController {
    // MARK: - Enums
    enum SettingsScreenConstants {
        // cloudServiceLabel settings.
        static let cloudServiceLabelFontSize: CGFloat = 16
        static let cloudServiceLabelLeading: CGFloat = 20
        static let cloudServiceLabelTop: CGFloat = 100
        
        // logoutBtn settings.
        static let logoutBtnHeight: CGFloat = 50
        static let logoutBtnLeading: CGFloat = 20
        static let logoutBtnTop: CGFloat = 20
    }
    
    // MARK: - Variables
    private let interactor: SettingsScreenBusinessLogic
    
    // UI components.
    private let cloudServiceLabel: UILabel = UILabel()
    private let logoutBtn: UIButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    init(interactor: SettingsScreenBusinessLogic) {
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
        interactor.loadStart(SettingsScreenModel.Start.Request())
    }
    
    // MARK: - Actions
    @objc private func logoutBtnTapped() {
        interactor.logoutFromService(SettingsScreenModel.Logout.Request())
    }
    
    // MARK: - Public methods
    func displayStart(_ viewModel: SettingsScreenModel.Start.ViewModel) {
        cloudServiceLabel.text = viewModel.cloudServiceName
    }
    
    // MARK: - Private methods
    private func configureUI() {
        // Set the background color to the default one from the assets.
        view.backgroundColor = UIColor(named: "Background")
        
        configureCloudServiceLabel()
        configureLogoutBtn()
    }
    
    private func configureCloudServiceLabel() {
        view.addSubview(cloudServiceLabel)
        
        // CloudServiceLabel settings.
        cloudServiceLabel.font = .systemFont(ofSize: SettingsScreenConstants.cloudServiceLabelFontSize, weight: .medium)
        cloudServiceLabel.textColor = .black
        cloudServiceLabel.textAlignment = .justified
        
        // CloudServiceLabel constraints.
        cloudServiceLabel.pinLeft(to: view, SettingsScreenConstants.cloudServiceLabelLeading)
        cloudServiceLabel.pinTop(to: view, SettingsScreenConstants.cloudServiceLabelTop)
    }
    
    private func configureLogoutBtn() {
        view.addSubview(logoutBtn)
        
        // LogoutBtn settings.
        logoutBtn.backgroundColor = .none
        logoutBtn.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        logoutBtn.setTitle("Выйти", for: .normal)
        
        logoutBtn.setHeight(SettingsScreenConstants.logoutBtnHeight)
        
        logoutBtn.addTarget(self, action: #selector(logoutBtnTapped), for: .touchUpInside)
        
        // LogoutBtn constraints.
        logoutBtn.pinTop(to: cloudServiceLabel, SettingsScreenConstants.logoutBtnTop)
        logoutBtn.pinLeft(to: view, SettingsScreenConstants.logoutBtnLeading)
    }
}
