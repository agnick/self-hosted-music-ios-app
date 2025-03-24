//
//  AddToPlaylistWorker.swift
//  MusicApp
//
//  Created by Никита Агафонов on 06.03.2025.
//

import Foundation

final class AddToPlaylistWorker: AddToPlaylistWorkerProtocol {
    private let userDefaults = UserDefaults.standard
    
    func loadSortPreference() -> SortType {
        if let rawValue = userDefaults.string(forKey: UserDefaultsKeys.sortKey), let savedSort = SortType(rawValue: rawValue) {
            return savedSort
        }
        
        return .titleAscending
    }
}
