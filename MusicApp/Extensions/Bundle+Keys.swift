//
//  Bundle+Keys.swift
//  MusicApp
//
//  Created by Никита Агафонов on 19.02.2025.
//

import Foundation

extension Bundle {
    var dropboxApiKey: String {
        return object(forInfoDictionaryKey: "DROPBOX_API_KEY") as? String ?? ""
    }
}
