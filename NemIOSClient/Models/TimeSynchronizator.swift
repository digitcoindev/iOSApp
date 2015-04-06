import UIKit
private var once = dispatch_once_t()

class TimeSynchronizator
{
    struct Store
    {
        static var isSynchronized :Bool = false
        static var nemTime :Double = 0
        static var appTime :NSDate = NSDate()
        static let observers :NSNotificationCenter = NSNotificationCenter.defaultCenter()
    }

    final class var isSynchronized: Bool
    {
        get
        {
            return TimeSynchronizator.Store.isSynchronized
        }
        set
        {
            TimeSynchronizator.Store.isSynchronized = newValue
        }
    }
    
    final class var nemTime: Double
    {
        get
        {
            return Store.nemTime + NSDate().timeIntervalSinceDate(Store.appTime)
        }
        set
        {
            Store.nemTime = newValue
            Store.appTime = NSDate()
            Store.isSynchronized = true
        }
    }
    
    final class func synchronize()
    {
        if State.currentServer != nil
        {
            APIManager().timeSynchronize(State.currentServer!)
        }
    }
}
