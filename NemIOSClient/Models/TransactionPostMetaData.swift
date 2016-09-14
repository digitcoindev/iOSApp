import UIKit

class TransactionPostMetaData: NSObject
{
    var id :Double!
    var height :Double!
    var hashString :String!
    var signature :String!
    var data :String?
    
    var type :Int = 0
    var version :Double!
    var timeStamp :Double!
    var privateKey :String!
    var signer :String!
    var fee :Double!
    var deadline :Double!
    var publicKeys :[String] = [String]()
    
    override init() {
        
    }
    
    func getFrom(_ dictionary: NSDictionary) {
        
    }
    
    func getBeginFrom(_ dictionary: NSDictionary) {
        self.id = dictionary.object(forKey: "id") as! Double
        self.height = dictionary.object(forKey: "height") as! Double
        self.hashString = (dictionary.object(forKey: "hash")! as AnyObject).object(forKey: "data") as! String
    }
}
