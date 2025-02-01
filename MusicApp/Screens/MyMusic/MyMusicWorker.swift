//
//  MyMusicWorker.swift
//  MusicApp
//
//  Created by Никита Агафонов on 29.01.2025.
//

import Foundation

final class MyMusicWorker : MyMusicWorkerProtocol {
    private let userDefaults = UserDefaults.standard
    
    func saveSortPreference(_ sortType: SortType) {
        userDefaults.set(sortType.rawValue, forKey: UserDefaultsKeys.sortKey)
    }
    
    func loadSortPreference() -> SortType {
        if let rawValue = userDefaults.string(forKey: UserDefaultsKeys.sortKey), let savedSort = SortType(rawValue: rawValue) {
            return savedSort
        }
        
        return .titleAscending
    }
}
