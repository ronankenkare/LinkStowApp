import Foundation

extension UserDefaults {
    private enum Keys {
        static let hiddenGroupActive = "hiddenGroupActive"
        static let titleLineLimit = "titleLineLimit"
        static let captionLineLimit = "captionLineLimit"
    }
    
    var hiddenGroupActive: Bool {
        get {
            return bool(forKey: Keys.hiddenGroupActive)
        }
        set {
            set(newValue, forKey: Keys.hiddenGroupActive)
        }
    }
    
    var titleLineLimit: Int {
        get {
            return integer(forKey: Keys.titleLineLimit)
        }
        set {
            set(newValue, forKey: Keys.titleLineLimit)
        }
    }
    
    var captionLineLimit: Int {
        get {
            return integer(forKey: Keys.captionLineLimit)
        }
        set {
            set(newValue, forKey: Keys.captionLineLimit)
        }
    }
}
