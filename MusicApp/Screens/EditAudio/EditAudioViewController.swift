import UIKit

protocol EditAudioViewControllerDelegate: AnyObject {
    func editAudioViewControllerDidFinishEditing(_ controller: EditAudioViewController)
}

final class EditAudioViewController: UIViewController {
    // MARK: - Enums
    enum Constants {
        // pickImageButton settings.
        static let pickImgButtonTop: CGFloat = 20
        static let pickImgButtonLeading: CGFloat = 20
        static let pickImgButtonSize: CGFloat = 250
        static let pickImgButtonCornerRadius: CGFloat = 10
        
        // textFieldsStackView settings
        static let textFieldsStackViewTop: CGFloat = 20
        static let textFieldsStackViewOffset: CGFloat = 20
        static let textFieldsStackViewSpacing: CGFloat = 20
        static let textFieldsStackSubviewSpacing: CGFloat = 5
    }
    
    // MARK: - Variables
    private let interactor: EditAudioBusinessLogic
    weak var delegate: EditAudioViewControllerDelegate?
    
    // UI components.
    private var cancelButton: UIBarButtonItem?
    private var approveButton: UIBarButtonItem?
    private let pickImgButton: UIButton = UIButton()
    private let textFieldsStackView: UIStackView = UIStackView()
    private let audioNameLabel: UILabel = UILabel()
    private let artistNameLabel: UILabel = UILabel()
    private var audioNameTextField: UITextField?
    private var artistNameTextField: UITextField?
    
    // MARK: - Lifecycle
    init(interactor: EditAudioBusinessLogic) {
        self.interactor = interactor
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(parameters:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setHidesBackButton(true, animated: false)
        
        // Configure all UI elements and layout.
        configureUI()
        configureTapGestures()
        
        // Load current track info.
        interactor.loadStart()
    }
    
    // MARK: - Tab bar actions
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func approveButtonTapped() {
        guard
            let name = audioNameTextField?.text,
            let artistName = artistNameTextField?.text
        else {
            presentAlert(title: "Ошибка", message: "Заполните все поля", actions: [])
            return
        }
        
        let newImage = pickImgButton.backgroundImage(for: .normal)
        
        interactor.saveAudioFileChanges(EditAudioModel.EditData.Request(name: name, artistName: artistName, image: newImage))
        
        delegate?.editAudioViewControllerDidFinishEditing(self)
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Keyboard actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Audio edit actions
    @objc private func pickImgButtonTapped() {
        interactor.loadImagePicker()
    }
    
    // MARK: - Public methods
    func displayStart(_ viewModel: EditAudioModel.Start.ViewModel) {
        pickImgButton.setBackgroundImage(viewModel.image, for: .normal)
        audioNameTextField?.text = viewModel.name
        artistNameTextField?.text = viewModel.artistName
    }
    
    func displayImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    func displayPickedImage(_ viewModel: EditAudioModel.AudioImage.ViewModel) {
        pickImgButton.setBackgroundImage(viewModel.image, for: .normal)
    }
    
    func displayError(_ viewModel: EditAudioModel.Error.ViewModel) {
        let actions = [UIAlertAction(title: "OK", style: .default)]
        
        self.presentAlert(title: "Ошибка", message: viewModel.errorDescription, actions: actions)
    }
    
    // MARK: - Private methods
    private func configureUI() {
        view.backgroundColor = UIColor(color: .background)
        
        configureNavigationBar()
        configurePickImgButton()
        configureTextFieldsStackView()
    }
    
    private func configureNavigationBar() {
        let cancelButton = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(cancelButtonTapped))
        
        let approveButton = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(approveButtonTapped))
        
        self.cancelButton = cancelButton
        self.approveButton = approveButton
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = approveButton
    }
    
    private func configurePickImgButton() {
        view.addSubview(pickImgButton)
        
        pickImgButton.contentMode = .scaleAspectFill
        pickImgButton.clipsToBounds = true
        pickImgButton.layer.cornerRadius = Constants.pickImgButtonCornerRadius
        
        pickImgButton.addTarget(self, action: #selector(pickImgButtonTapped), for: .touchUpInside)
        
        pickImgButton.pinTop(to: view.safeAreaLayoutGuide.topAnchor, Constants.pickImgButtonTop)
        pickImgButton.pinLeft(to: view, Constants.pickImgButtonLeading)
        pickImgButton.setHeight(Constants.pickImgButtonSize)
        pickImgButton.setWidth(Constants.pickImgButtonSize)
    }
    
    private func configureTextFieldsStackView() {
        view.addSubview(textFieldsStackView)
        
        textFieldsStackView.axis = .vertical
        textFieldsStackView.spacing = Constants.textFieldsStackViewSpacing
        
        let audioNameStack = UIStackView()
        audioNameStack.axis = .vertical
        audioNameStack.spacing = Constants.textFieldsStackSubviewSpacing
        
        let audioNameTextField: UITextField = UITextField()
        audioNameTextField.borderStyle = .roundedRect
        
        audioNameLabel.text = "Название"
        audioNameLabel.textColor = .lightGray
        audioNameLabel.textAlignment = .left
        
        audioNameStack.addArrangedSubview(audioNameLabel)
        audioNameStack.addArrangedSubview(audioNameTextField)
        
        let artistNameStack = UIStackView()
        artistNameStack.axis = .vertical
        artistNameStack.spacing = Constants.textFieldsStackSubviewSpacing
        
        let artistNameTextField: UITextField = UITextField()
        artistNameTextField.borderStyle = .roundedRect
        
        artistNameLabel.text = "Исполнитель"
        artistNameLabel.textColor = .lightGray
        artistNameLabel.textAlignment = .left
        
        artistNameStack.addArrangedSubview(artistNameLabel)
        artistNameStack.addArrangedSubview(artistNameTextField)
        
        textFieldsStackView.addArrangedSubview(audioNameStack)
        textFieldsStackView.addArrangedSubview(artistNameStack)
        
        self.audioNameTextField = audioNameTextField
        self.artistNameTextField = artistNameTextField
        
        audioNameTextField.delegate = self
        artistNameTextField.delegate = self
        
        textFieldsStackView.pinTop(to: pickImgButton.bottomAnchor, Constants.textFieldsStackViewTop)
        textFieldsStackView.pinHorizontal(to: view, Constants.textFieldsStackViewOffset)
    }
    
    private func configureTapGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension EditAudioViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        interactor.loadPickedPlaylistImage(EditAudioModel.AudioImage.Request(imageData: info[.originalImage]))
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension EditAudioViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
