//
//  NewPlaylistViewController.swift
//  MusicApp
//
//  Created by Никита Агафонов on 04.03.2025.
//

import UIKit
import UniformTypeIdentifiers

final class NewPlaylistViewController: UIViewController {
    // MARK: - Enums
    enum Constants {
        // editPlaylistStackView settings.
        static let editPlaylistStackViewTop: CGFloat = 20
        static let editPlaylistStackViewOffset: CGFloat = 20
        static let editPlaylistStackViewHeight: CGFloat = 200
        static let editPlaylistStackViewSpacing: CGFloat = 10
        
        // playlistNameTextView settings
        static let playlistNameTextFontSize: CGFloat = 17
        static let placeholderText: String = "Название плейлиста"
        
        // pickImageButton settings.
        static let pickImageButtonSize: CGFloat = 200
        
        // addTracksButton settings.
        static let addTracksButtonPadding: CGFloat = 10
        static let addTracksButtonFontSize: CGFloat = 18
        static let addTracksButtonTop: CGFloat = 20
        static let addTracksButtonOffset: CGFloat = 20
        
        // audioTable settings.
        static let audioTableViewTop: CGFloat = 10
        static let audioTableOffset: CGFloat = 20
        static let audioTableBottom: CGFloat = 10
        static let audioTableRowHeight: CGFloat = 90
    }
    
    // MARK: - Variables
    // Playlists screen interactor, it contains all bussiness logic.
    private let interactor: (NewPlaylistBusinessLogic & NewPlaylistDataStore)
    
    /* UI components */
    // View stacks.
    private let editPlaylistStackView: UIStackView = UIStackView()
    
    // Buttons.
    private var cancelButton: UIBarButtonItem?
    private var approveButton: UIBarButtonItem?
    private var pickImageButton: UIButton?
    private let addTracksButton: UIButton = UIButton(type: .system)
    
    // TextFields
    private var playlistNameTextView: UITextView?
    
    // Other components.
    private let audioTable: UITableView = UITableView(frame: .zero)
    
    // MARK: - Lifecycle
    init(interactor: (NewPlaylistBusinessLogic & NewPlaylistDataStore)) {
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
    }
    
    // MARK: - Tab bar actions
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func approveButtonTapped() {
        interactor.savePlaylist()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Playlist creation actions
    @objc private func pickImageButtonTapped() {
        interactor.loadImagePicker()
    }
    
    @objc private func addTracksButtonTapped() {
        interactor.loadTrackPicker()
    }
    
    // MARK: - Public methods
    func displayCellData(_ viewModel: NewPlaylistModel.CellData.ViewModel) {
        guard let cell = audioTable.cellForRow(at: IndexPath(row: viewModel.index, section: 0)) as? PlaylistEditAudioCell else { return }
        
        cell.configure(audioName: viewModel.name, artistName: viewModel.artistName, duration: viewModel.durationInSeconds)
    }
    
    func displaySelectedTracks() {
        audioTable.reloadData()
    }
    
    func displayImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    func displayPickedImage(_ viewModel: NewPlaylistModel.PlaylistImage.ViewModel) {
        pickImageButton?.setBackgroundImage(viewModel.image, for: .normal)
    }
    
    func displayError(_ viewModel: NewPlaylistModel.Error.ViewModel) {
        let actions = [UIAlertAction(title: "OK", style: .default)]
        
        self.presentAlert(title: "Ошибка", message: viewModel.errorDescription, actions: actions)
    }
    
    // MARK: - Private methods for UI configuring
    private func configureUI() {
        view.backgroundColor = UIColor(color: .background)
        
        configureNavigationBar()
        configureEditPlaylistStackView()
        configureAddTracksButton()
        configureAudioTable()
    }
    
    private func configureNavigationBar() {
        let cancelButton = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(cancelButtonTapped))
        
        let approveButton = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(approveButtonTapped))
        
        self.cancelButton = cancelButton
        self.approveButton = approveButton
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = approveButton
    }
    
    private func configureEditPlaylistStackView() {
        view.addSubview(editPlaylistStackView)
        
        editPlaylistStackView.axis = .horizontal
        editPlaylistStackView.distribution = .fill
        editPlaylistStackView.spacing = Constants.editPlaylistStackViewSpacing
        
        // Image settings.
        let pickImageButton: UIButton = UIButton()
        pickImageButton.setBackgroundImage(UIImage(image: .icPickImage), for: .normal)
        pickImageButton.contentMode = .scaleAspectFill
        pickImageButton.clipsToBounds = true
        
        pickImageButton.addTarget(self, action: #selector(pickImageButtonTapped), for: .touchUpInside)
        
        pickImageButton.setWidth(Constants.pickImageButtonSize)
        pickImageButton.setHeight(Constants.pickImageButtonSize)
        
        // Text view settings.
        let playlistNameTextView: UITextView = UITextView()
        playlistNameTextView.text = Constants.placeholderText
        playlistNameTextView.textColor = .lightGray
        playlistNameTextView.font = .systemFont(ofSize: Constants.playlistNameTextFontSize, weight: .semibold)
        playlistNameTextView.isScrollEnabled = true
        
        playlistNameTextView.delegate = self
        
        // Add to stack.
        self.pickImageButton = pickImageButton
        self.playlistNameTextView = playlistNameTextView
        
        editPlaylistStackView.addArrangedSubview(pickImageButton)
        editPlaylistStackView.addArrangedSubview(playlistNameTextView)
        
        // Stack settings.
        editPlaylistStackView.pinTop(to: view.safeAreaLayoutGuide.topAnchor, Constants.editPlaylistStackViewTop)
        editPlaylistStackView.pinHorizontal(to: view, Constants.editPlaylistStackViewOffset)
        editPlaylistStackView.setHeight(Constants.editPlaylistStackViewHeight)
    }
    
    private func configureAddTracksButton() {
        view.addSubview(addTracksButton)
        
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(image: .icAddIntoPlaylist)
        configuration.baseBackgroundColor = .clear
        configuration.baseForegroundColor = .black
        configuration.imagePadding = Constants.addTracksButtonPadding
        configuration.imagePlacement = .leading
        configuration.contentInsets = .zero
        
        let title = "Добавить музыку"
        var attributedTitle = AttributedString(title)
        attributedTitle.font =
            .systemFont(
                ofSize: Constants.addTracksButtonFontSize,
                weight: .semibold
            )
        attributedTitle.foregroundColor = UIColor(
            color: .primary
        )
        configuration.attributedTitle = attributedTitle
            
        addTracksButton.configuration = configuration
        addTracksButton.contentHorizontalAlignment = .left
        
        addTracksButton.addTarget(self, action: #selector(addTracksButtonTapped), for: .touchUpInside)
        
        addTracksButton.pinTop(to: editPlaylistStackView.bottomAnchor, Constants.addTracksButtonTop)
        addTracksButton.pinHorizontal(to: view, Constants.addTracksButtonOffset)
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
                PlaylistEditAudioCell.self,
                forCellReuseIdentifier: PlaylistEditAudioCell.reuseId
            )
        
        audioTable.isScrollEnabled = true
        audioTable.alwaysBounceVertical = true
        audioTable.contentInset = .zero
        audioTable.contentInsetAdjustmentBehavior = .never
        
        // Set constraints to position the table view.
        audioTable
            .pinTop(
                to: addTracksButton.bottomAnchor, Constants.audioTableViewTop)
        audioTable.pinHorizontal(to: view, Constants.audioTableOffset)
        audioTable.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, Constants.audioTableBottom)
    }
}

// MARK: - UITextViewDelegate
extension NewPlaylistViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == Constants.placeholderText && textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.placeholderText
            textView.textColor = .lightGray
        } else {
            interactor.loadPlaylistName(NewPlaylistModel.PlaylistName.Request(playlistName: textView.text))
        }
    }
}

// MARK: - AddToPlaylistDelegate
extension NewPlaylistViewController: AddToPlaylistDelegate {
    func didSelectAudioFiles(_ audioFiles: [AudioFile]) {
        interactor.loadSelectedTracks(NewPlaylistModel.SelectedTracks.Request(audioFiles: audioFiles))
    }
}

// MARK: - UITableViewDataSource
extension NewPlaylistViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interactor.selectedTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: PlaylistEditAudioCell.reuseId,
            for: indexPath
        ) as! PlaylistEditAudioCell
        
        interactor.getCellData(NewPlaylistModel.CellData.Request(index: indexPath.row))
        
        cell.deleteAction = { [weak self] in
            guard
                let self = self,
                let currentIndexPath = tableView.indexPath(for: cell)
            else {
                return
            }
            
            self.interactor.removeTrack(NewPlaylistModel.RemoveTrack.Request(index: currentIndexPath.row))
            tableView.deleteRows(at: [currentIndexPath], with: .automatic)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NewPlaylistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.audioTableRowHeight
    }
}

// MARK: - UIDocumentPickerDelegate
extension NewPlaylistViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        interactor.loadPickedPlaylistImage(NewPlaylistModel.PlaylistImage.Request(imageData: info[.originalImage]))
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
