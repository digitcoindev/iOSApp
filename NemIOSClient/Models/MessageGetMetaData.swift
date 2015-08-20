import UIKit

class MessageGetMetaData: NSObject
{
    private var _payload :String!
    var payload :String {
        get {
            return _payload
        }
        set {
            _payload = newValue
        }
    }
    
    var type :Double!
}
