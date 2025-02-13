//
//  StartScreenViewController.swift
//  MusicApp
//
//  Created by Никита Агафонов on 24.12.2024.
//

import UIKit

final class StartScreenViewController: UIViewController {
    // MARK: - Enums
    enum Constants {
        // App name settings.
        static let appNameFontSize: CGFloat = 24
        static let appNameTop: CGFloat = 10
        
        // Start screen stack view settings.
        static let startScreenStackViewSpacing: CGFloat = 10
    }
    
    // MARK: - Variables
    private let interactor: StartScreenBusinessLogic
    
    // UI components.
    private let appLogo: UIImageView = UIImageView(image: UIImage(image: .icLogo))
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
        
        // Calling private method to configure UI components.
        configureUI()
        
        // Calling interactor to switch to the slider guide or main screen.
        interactor.determineNavigationDestination()
    }
    
    // MARK: - Private methods
    private func configureUI() {
        // Set the background color to the default one from the assets.
        view.backgroundColor = UIColor(color: .background)
        
        // Calling private methods to customize the UI.
        configureAppLogo()
        configureAppName()
        configureStartScreenStackView()
    }
    
    private func configureAppLogo() {
        view.addSubview(appLogo)
        
        appLogo.contentMode = .scaleAspectFit
    }
    
    private func configureAppName() {
        view.addSubview(appName)
        
        // Setting the font and text color.
        appName.font = .systemFont(ofSize: Constants.appNameFontSize, weight: .medium)
        appName.textColor = UIColor(color: .primary)
        appName.text = "Self-hosted Music"
    }
    
    private func configureStartScreenStackView() {
        // Configuring the arrangement of elements inside the stack view.
        startScreenStackView.axis = .vertical
        startScreenStackView.spacing = Constants.startScreenStackViewSpacing
        
        startScreenStackView.addArrangedSubview(appLogo)
        startScreenStackView.addArrangedSubview(appName)
        
        view.addSubview(startScreenStackView)
        
        // Setting up the stack constraints using UIView+Pin.
        startScreenStackView.pinCenter(to: view)
    }
}

