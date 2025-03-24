//
//  TabViewController.swift
//  MusicApp
//
//  Created by Никита Агафонов on 31.12.2024.
//

import UIKit

final class TabViewController: UITabBarController {
    // MARK: - Variables
    private let miniPlayerView = MiniPlayerView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabs()
        setupMiniPlayerView()
    }
    
    // MARK: - Configure Tab Bar
    private func setupTabs() {
        // Create the tabs for the screens and add them to the tab bar.
        let importScreen = createNav(
            with: "Импорт",
            and: UIImage(image: .icAudioImport),
            vc: AudioImportAssembly.build()
        )
        let myMusicScreen = createNav(
            with: "Моя музыка",
            and: UIImage(image: .icMyMusic),
            vc: MyMusicAssembly.build()
        )
        let playlistsScreen = createNav(
            with: "Плейлисты",
            and: UIImage(image: .icPlaylists),
            vc: PlaylistsAssembly.build()
        )
        let settingsScreen = createNav(
            with: "Дополнительно",
            and: UIImage(image: .icSettings),
            vc: SettingsScreenAssembly.build()
        )
        
        // Add all tabs to the tab bar and animate the transition.
        self.setViewControllers(
            [importScreen, myMusicScreen, playlistsScreen, settingsScreen],
            animated: true
        )
    }
    
    private func createNav(with title: String, and image: UIImage?, vc: UIViewController) -> UINavigationController {
        // Initialize a UINavigationController with the provided view controller as its root.
        let nav = UINavigationController(rootViewController: vc)
        
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        
        return nav
    }
    
    private func setupMiniPlayerView() {
        miniPlayerView.delegate = self
        view.addSubview(miniPlayerView)
        
        miniPlayerView.pinLeft(to: view)
        miniPlayerView.pinRight(to: view)
        miniPlayerView.pinBottom(to: tabBar.topAnchor)
        miniPlayerView.setHeight(60)
    }
}

extension TabViewController: MiniPlayerViewDelegate {
    func miniPlayerNextTrackTapped(_ miniPlayerView: MiniPlayerView) {
        AudioPlayer.shared.playNextTrack()
    }
    
    func miniPlayerViewDidTap(_ miniPlayerView: MiniPlayerView) {
        let playerVC = PlayerAssembly.build()
        present(playerVC, animated: true)
    }
    
    func miniPlayerPlayPauseTapped(_ miniPlayerVie: MiniPlayerView) {
        AudioPlayer.shared.togglePlayPause()
    }
}
