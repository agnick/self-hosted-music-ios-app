//
//  TabViewController.swift
//  MusicApp
//
//  Created by Никита Агафонов on 31.12.2024.
//

import UIKit

final class TabViewController: UITabBarController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabs()
    }
    
    // MARK: - Configure Tab Bar
    private func setupTabs() {
        // Create the tabs for the screens and add them to the tab bar.
        let importScreen = createNav(
            with: "Импорт",
            and: UIImage(named: "ic-import-screen"),
            vc: ImportScreenAssembly.build()
        )
        let myMusicScreen = createNav(
            with: "Моя музыка",
            and: UIImage(named: "ic-my-music-screen"),
            vc: ImportScreenAssembly.build()
        )
        let playlistsScreen = createNav(
            with: "Плейлисты",
            and: UIImage(named: "ic-playlists-screen"),
            vc: ImportScreenAssembly.build()
        )
        let settingsScreen = createNav(
            with: "Дополнительно",
            and: UIImage(named: "ic-settings-screen"),
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
}
