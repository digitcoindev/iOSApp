import UIKit
private var once = Int()

class TimeSynchronizator
{
    struct Store {
        static var isSynchronized :Bool = false
        static var nemTime :Double = 0
        static var appTime :Date = Date()
        static let observers :NotificationCenter = NotificationCenter.default
    }

    final class var isSynchronized: Bool {
        get {
            return TimeSynchronizator.Store.isSynchronized
        }
        set {
            TimeSynchronizator.Store.isSynchronized = newValue
        }
    }
    
    final class var nemTime: Double {
        get {
            return Store.nemTime + Date().timeIntervalSince(Store.appTime)
        }
        set {
            Store.nemTime = newValue
            Store.appTime = Date()
            Store.isSynchronized = true
        }
    }
    
    final class func synchronize() {
        if State.currentServer != nil {
            APIManager().timeSynchronize(State.currentServer!)
        }
    }
}
