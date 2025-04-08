//
//  PlaylistsWorker.swift
//  MusicApp
//
//  Created by Никита Агафонов on 07.04.2025.
//

import Foundation

protocol PlaylistsWorkerProtocol {
    func saveSortPreference(_ sortType: SortType)
    func loadSortPreference() -> SortType
}

final class PlaylistsWorker: PlaylistsWorkerProtocol {
    private let userDefaults = UserDefaults.standard
    
    func saveSortPreference(_ sortType: SortType) {
        userDefaults.set(sortType.rawValue, forKey: UserDefaultsKeys.sortPlaylistsKey)
    }
    
    func loadSortPreference() -> SortType {
        if let rawValue = userDefaults.string(forKey: UserDefaultsKeys.sortPlaylistsKey), let savedSort = SortType(rawValue: rawValue) {
            return savedSort
        }
        
        return .titleAscending
    }
}
