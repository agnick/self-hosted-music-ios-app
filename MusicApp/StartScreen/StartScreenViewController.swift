//
//  StartScreenViewController.swift
//  MusicApp
//
//  Created by Никита Агафонов on 24.12.2024.
//

import UIKit

final class StartScreenViewController: UIViewController {
    // MARK: - Enums
    enum StartScreenConstants {
        // App name settings.
        static let appNameFontSize: CGFloat = 24
        static let appNameTop: CGFloat = 10
        
        // Start screen stack view settings.
        static let startScreenStackViewSpacing: CGFloat = 10
    }
    
    // MARK: - Variables
    private let interactor: StartScreenBusinessLogic
    
    // UI components.
    private let appLogo: UIImageView = UIImageView(image: UIImage(named: "ic-logo"))
    private let appName: UILabel = UILabel()
    private let startScreenStackView: UIStackView = UIStackView()
    

    // MARK: - Lifecycle
    init(interactor: StartScreenBusinessLogic) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(parameters:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the background color to the default one from the assets.
        view.backgroundColor = UIColor(named: "Background")
        
        // Calling private methods to customize the UI.
        configureAppLogo()
        configureAppName()
        configureStartScreenStackView()
        
        // Calling interactor to switch to the slider guide or main screen.
        interactor.determineNavigationDestination(StartScreenModel.NavigationDestination.Request())
    }
    
    // MARK: - Private methods
    private func configureAppLogo() {
        view.addSubview(appLogo)
        
        appLogo.contentMode = .scaleAspectFit
    }
    
    private func configureAppName() {
        view.addSubview(appName)
        
        // Setting the font and text color.
        appName.font = .systemFont(ofSize: StartScreenConstants.appNameFontSize, weight: .medium)
        appName.textColor = UIColor(named: "AccentColor")
        appName.text = "Self-hosted Music"
    }
    
    private func configureStartScreenStackView() {
        // Configuring the arrangement of elements inside the stack view.
        startScreenStackView.axis = .vertical
        startScreenStackView.spacing = StartScreenConstants.startScreenStackViewSpacing
        
        startScreenStackView.addArrangedSubview(appLogo)
        startScreenStackView.addArrangedSubview(appName)
        
        view.addSubview(startScreenStackView)
        
        // Setting up the stack constraints using UIView+Pin.
        startScreenStackView.pinCenter(to: view)
    }
}

