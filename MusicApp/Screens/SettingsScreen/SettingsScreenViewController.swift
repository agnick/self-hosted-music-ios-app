import UIKit

final class SettingsScreenViewController: UIViewController {
    // MARK: - Enums
    private enum Constants {
        // titleLabel settings.
        static let titleLabelFontSize: CGFloat = 32
        static let titleLabelLeading: CGFloat = 20
        
        // Wraps settings.
        static let wrapAlpha: CGFloat = 0.2
        static let wrapCornerRadius: CGFloat = 10
        static let wrapLabelsFontSize: CGFloat = 14
        
        // appVersionWrap settings.
        static let appVersionWrapOffset: CGFloat = 20
        static let appVersionWrapTop: CGFloat = 20
        static let appVersionWrapHeight: CGFloat = 30
        
        // versionImage settings.
        static let versionImageLeading: CGFloat = 20
        static let versionImageSize: CGFloat = 20
        
        // versionLabel settings.
        static let versionLabelLeading: CGFloat = 15
        
        // appVersionLabel settings.
        static let appVersionLabelTrailing: CGFloat = 20
        
        // memoryLabel settings.
        static let memoryLabelFontSize: CGFloat = 20
        static let memoryLabelTop: CGFloat = 20
        static let memoryLabelLeading: CGFloat = 20
        
        // memoryWrap settings.
        static let memoryWrapTop: CGFloat = 10
        static let memoryWrapHeight: CGFloat = 80
        
        // freeMemoryLabel settings.
        static let freeMemoryLabelFontSize: CGFloat = 20
        
        // usedMemoryLabel settings.
        static let usedMemoryLabelFontSize: CGFloat = 20
        
        // memoryHorizontalStack settings.
        static let memoryHorizontalStackSpacing: CGFloat = 20
        static let memoryHorizontalStackVerticalOffset: CGFloat = 5
        static let memoryHorizontalStackHorizontalOffset: CGFloat = 10
        
        // connectedCloudLabel settings.
        static let cloudLabelFontSize: CGFloat = 20
        static let cloudLabelTop: CGFloat = 20
        static let cloudLabelLeading: CGFloat = 20

        // cloudServiceWrap settings.
        static let cloudServiceWrapTop: CGFloat = 10
        static let cloudServiceWrapHeight: CGFloat = 40

        // cloudServiceImage settings.
        static let cloudImageLeading: CGFloat = 20
        static let cloudImageSize: CGFloat = 20

        // cloudServiceLabel settings.
        static let cloudServiceLabelLeading: CGFloat = 15

        // signOutButton settings.
        static let signOutTrailing: CGFloat = 20
    }
    
    // MARK: - Dependencies
    private let interactor: SettingsScreenBusinessLogic
    
    // MARK: - UI components
    private let titleLabel: UILabel = UILabel()
    private let appVersionWrap: UIView = UIView()
    private var appVersionLabel: UILabel?
    private let memoryLabel: UILabel = UILabel()
    private let memoryWrap: UIView = UIView()
    private var freeMemoryLabel: UILabel?
    private var usedMemoryLabel: UILabel?
    private let connectedCloudLabel: UILabel = UILabel()
    private let cloudServiceWrap: UIView = UIView()
    private var cloudServiceImageView: UIImageView?
    private var cloudServiceNameLabel: UILabel?
    private var signOutButton: UIButton?

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        interactor.loadStart()
        
        super.viewWillAppear(animated)
    }
    
    // MARK: - Actions
    @objc private func signOutButtonTapped() {
        let actions = [
            UIAlertAction(title: "Отмена", style: .default),
            UIAlertAction(title: "Да", style: .default) { [weak self] _ in
                guard
                    let self = self
                else {
                    return
                }
                
                self.interactor.logoutFromCloudService()
            }
        ]
        
        presentAlert(title: "Вы уверены что хотите выйти из аккаунта?", message: "", actions: actions)
    }
    
    // MARK: - Public methods
    func displayStart(_ viewModel: SettingsScreenModel.Start.ViewModel) {
        appVersionLabel?.text = viewModel.appVersion
        freeMemoryLabel?.text = "\(viewModel.freeMemoryGB) GB"
        usedMemoryLabel?.text = "\(viewModel.usedMemoryGB) GB"
        cloudServiceNameLabel?.text = viewModel.cloudServiceName
        cloudServiceImageView?.image = viewModel.cloudServiceImage
        
        signOutButton?.isHidden = !viewModel.isCloudServiceConnected
    }
    
    func displayError(_ viewModel: SettingsScreenModel.Error.ViewModel) {
        let actions = [UIAlertAction(title: "OK", style: .default)]
        
        self.presentAlert(title: "Ошибка", message: viewModel.errorDescription, actions: actions)
    }
    
    // MARK: - Private methods
    private func configureUI() {
        // Set the background color to the default one from the assets.
        view.backgroundColor = UIColor(color: .background)
        
        configureTitleLabel()
        configureAppVersionBlock()
        configureMemoryLabel()
        configureMemoryWrap()
        configureCloudStorageLabel()
        configureCloudStorageWrap()
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
        titleLabel.text = "Дополнительно"
        
        // Set constraints to position the title label.
        titleLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.pinLeft(to: view, Constants.titleLabelLeading)
    }
    
    private func configureAppVersionBlock() {
        view.addSubview(appVersionWrap)
        
        appVersionWrap.backgroundColor = .lightGray.withAlphaComponent(Constants.wrapAlpha)
        appVersionWrap.layer.cornerRadius = Constants.wrapCornerRadius
        
        let versionImage = UIImageView(image: UIImage(image: .icVersion))
        versionImage.contentMode = .scaleAspectFit
        versionImage.clipsToBounds = true
        
        let versionLabel = UILabel()
        versionLabel.text = "Версия"
        versionLabel.textColor = .black
        versionLabel.font = .systemFont(ofSize: Constants.wrapLabelsFontSize, weight: .semibold)
        
        let appVersionLabel = UILabel()
        appVersionLabel.textColor = .black
        appVersionLabel.font = .systemFont(ofSize: Constants.wrapLabelsFontSize, weight: .semibold)
        
        appVersionWrap.addSubview(versionImage)
        appVersionWrap.addSubview(versionLabel)
        appVersionWrap.addSubview(appVersionLabel)
        
        self.appVersionLabel = appVersionLabel
                
        versionImage.pinLeft(to: appVersionWrap.leadingAnchor, Constants.versionImageLeading)
        versionImage.pinCenterY(to: appVersionWrap)
        versionImage.setWidth(Constants.versionImageSize)
        versionImage.setHeight(Constants.versionImageSize)
        
        versionLabel.pinLeft(to: versionImage.trailingAnchor, Constants.versionLabelLeading)
        versionLabel.pinCenterY(to: appVersionWrap)
        
        appVersionLabel.pinRight(to: appVersionWrap.trailingAnchor, Constants.appVersionLabelTrailing)
        appVersionLabel.pinCenterY(to: appVersionWrap)
                
        appVersionWrap.pinHorizontal(to: view, Constants.appVersionWrapOffset)
        appVersionWrap.pinTop(to: titleLabel.bottomAnchor, Constants.appVersionWrapTop)
        appVersionWrap.setHeight(Constants.appVersionWrapHeight)
    }
    
    private func configureMemoryLabel() {
        view.addSubview(memoryLabel)
        
        memoryLabel.text = "Память"
        memoryLabel.textColor = .black
        memoryLabel.font = .systemFont(ofSize: Constants.memoryLabelFontSize, weight: .semibold)
        
        memoryLabel.pinTop(to: appVersionWrap.bottomAnchor, Constants.memoryLabelTop)
        memoryLabel.pinLeft(to: view, Constants.memoryLabelLeading)
    }
    
    private func configureMemoryWrap() {
        view.addSubview(memoryWrap)

        memoryWrap.backgroundColor = .lightGray.withAlphaComponent(Constants.wrapAlpha)
        memoryWrap.layer.cornerRadius = Constants.wrapCornerRadius

        // MARK: - Free Memory Stack
        let freeTitle = UILabel()
        freeTitle.text = "Свободно"
        freeTitle.textColor = .lightGray
        freeTitle.font = .systemFont(ofSize: Constants.wrapLabelsFontSize, weight: .semibold)

        let freeValue = UILabel()
        freeValue.textColor = .black
        freeValue.font = .systemFont(ofSize: Constants.freeMemoryLabelFontSize, weight: .semibold)

        self.freeMemoryLabel = freeValue

        let freeStack = UIStackView(arrangedSubviews: [freeTitle, freeValue])
        freeStack.axis = .vertical
        freeStack.alignment = .center
        freeStack.distribution = .fillEqually

        // MARK: - Used Memory Stack
        let usedTitle = UILabel()
        usedTitle.text = "Использовано"
        usedTitle.textColor = .lightGray
        usedTitle.font = .systemFont(ofSize: Constants.wrapLabelsFontSize, weight: .semibold)

        let usedValue = UILabel()
        usedValue.textColor = .black
        usedValue.font = .systemFont(ofSize: Constants.usedMemoryLabelFontSize, weight: .semibold)

        self.usedMemoryLabel = usedValue

        let usedStack = UIStackView(arrangedSubviews: [usedTitle, usedValue])
        usedStack.axis = .vertical
        usedStack.alignment = .center
        usedStack.distribution = .fillEqually

        // MARK: - Horizontal Stack for both
        let horizontalStack = UIStackView(arrangedSubviews: [freeStack, usedStack])
        horizontalStack.axis = .horizontal
        horizontalStack.distribution = .fillEqually
        horizontalStack.spacing = Constants.memoryHorizontalStackSpacing

        memoryWrap.addSubview(horizontalStack)

        // MARK: - Layout
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        memoryWrap.pinHorizontal(to: view, Constants.appVersionWrapOffset)
        memoryWrap.pinTop(to: memoryLabel.bottomAnchor, Constants.memoryWrapTop)
        memoryWrap.setHeight(Constants.memoryWrapHeight)

        horizontalStack.pinVertical(to: memoryWrap, Constants.memoryHorizontalStackVerticalOffset)
        horizontalStack.pinHorizontal(to: memoryWrap, Constants.memoryHorizontalStackHorizontalOffset)
    }
    
    private func configureCloudStorageLabel() {
        view.addSubview(connectedCloudLabel)
        
        connectedCloudLabel.text = "Подключенное облачное хранилище"
        connectedCloudLabel.textColor = .black
        connectedCloudLabel.font = .systemFont(ofSize: Constants.cloudLabelFontSize, weight: .semibold)
        
        connectedCloudLabel.pinTop(to: memoryWrap.bottomAnchor, Constants.cloudLabelTop)
        connectedCloudLabel.pinLeft(to: view, Constants.cloudLabelLeading)
    }

    private func configureCloudStorageWrap() {
        view.addSubview(cloudServiceWrap)
        
        cloudServiceWrap.backgroundColor = .lightGray.withAlphaComponent(Constants.wrapAlpha)
        cloudServiceWrap.layer.cornerRadius = Constants.wrapCornerRadius
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        let serviceLabel = UILabel()
        serviceLabel.textColor = .black
        serviceLabel.font = .systemFont(ofSize: Constants.wrapLabelsFontSize, weight: .semibold)
        
        let button = UIButton(type: .system)
        button.setTitle("Выйти", for: .normal)
        button.setTitleColor(UIColor(color: .primary), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.wrapLabelsFontSize, weight: .semibold)
        button.addTarget(self, action: #selector(signOutButtonTapped), for: .touchUpInside)
        
        cloudServiceWrap.addSubview(imageView)
        cloudServiceWrap.addSubview(serviceLabel)
        cloudServiceWrap.addSubview(button)
        
        self.cloudServiceImageView = imageView
        self.cloudServiceNameLabel = serviceLabel
        self.signOutButton = button
        
        imageView.pinLeft(to: cloudServiceWrap.leadingAnchor, Constants.cloudImageLeading)
        imageView.pinCenterY(to: cloudServiceWrap)
        imageView.setWidth(Constants.cloudImageSize)
        imageView.setHeight(Constants.cloudImageSize)
        
        serviceLabel.pinLeft(to: imageView.trailingAnchor, Constants.cloudLabelLeading)
        serviceLabel.pinCenterY(to: cloudServiceWrap)
        
        button.pinRight(to: cloudServiceWrap.trailingAnchor, Constants.signOutTrailing)
        button.pinCenterY(to: cloudServiceWrap)
        
        cloudServiceWrap.pinHorizontal(to: view, Constants.appVersionWrapOffset)
        cloudServiceWrap.pinTop(to: connectedCloudLabel.bottomAnchor, Constants.cloudServiceWrapTop)
        cloudServiceWrap.setHeight(Constants.cloudServiceWrapHeight)
    }
}
