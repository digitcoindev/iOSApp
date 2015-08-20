import UIKit

class TransactionPostMetaData
{
    var id :Double!
    var height :Double!
    var hash :String!
    var signature :String!
    var data :String!
    
    var type :Int = 0
    var version :Double!
    var timeStamp :Double!
    var privateKey :String!
    var signer :String!
    var fee :Double!
    var deadline :Double!
    var publicKeys :[String] = [String]()
    
    init() {
        
    }
    
    func getFrom(dictionary: NSDictionary) {
        
    }
    
    func getBeginFrom(dictionary: NSDictionary) {
        self.id = dictionary.objectForKey("id") as! Double
        self.height = dictionary.objectForKey("height") as! Double
        self.hash = dictionary.objectForKey("hash")!.objectForKey("data") as! String
    }
}
