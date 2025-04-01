import Foundation

class BaseENV {
    let dict: NSDictionary
    
    init(resourceName: String) {
        guard
            let filePath = Bundle.main.path(forResource: resourceName, ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: filePath)
        else {
            fatalError("Couldn`t find file '\(resourceName)' plist")
        }
        
        self.dict = plist
    }
}

final class DebugENV: BaseENV, APIKeyable {
    var DROPBOX_APP_KEY: String {
        dict.object(forKey: "DROPBOX_APP_KEY") as? String ?? ""
    }
    
    var GOOGLE_CLIENT_ID: String {
        dict.object(forKey: "GOOGLE_CLIENT_ID") as? String ?? ""
    }
    
    init() {
        super.init(resourceName: "DEBUG-keys")
    }
}

final class ProdENV: BaseENV, APIKeyable {    
    var DROPBOX_APP_KEY: String {
        dict.object(forKey: "DROPBOX_APP_KEY") as? String ?? ""
    }
    
    var GOOGLE_CLIENT_ID: String {
        dict.object(forKey: "GOOGLE_CLIENT_ID") as? String ?? ""
    }
    
    init() {
        super.init(resourceName: "PROD-keys")
    }
}
