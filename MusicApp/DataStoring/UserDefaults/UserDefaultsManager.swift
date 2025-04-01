import Foundation

final class UserDefaultsManager {
    private let userDefaults = UserDefaults.standard
    
    func saveSortPreference(_ sortType: SortType, for key: String) {
        userDefaults.set(sortType.rawValue, forKey: key)
    }
    
    func loadSortPreference(for key: String) -> SortType {
        guard
            let rawValue = userDefaults.string(forKey: key),
            let sortType = SortType(rawValue: rawValue)
        else {
            return .titleAscending
        }
        
        return sortType
    }    
}
