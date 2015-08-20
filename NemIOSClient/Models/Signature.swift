import UIKit

class Signature: NSObject
{
    var timeStamp :Double!
    var otherHash :String!
    var otherAccount :String!
    var signature :String!
    var fee :Double!
    var type :Double!
    var deadline :Double!
    var version :Double!
    var signer :String!

    final func fromDictionary(dictionary :NSDictionary) -> Signature {
        self.timeStamp = dictionary.objectForKey("timeStamp") as! Double
        self.otherHash = (dictionary.objectForKey("otherHash") as! NSDictionary).objectForKey("data") as! String
        self.otherAccount = dictionary.objectForKey("otherAccount") as! String
        self.signature = dictionary.objectForKey("signature") as! String
        self.fee = dictionary.objectForKey("fee") as! Double
        self.type = dictionary.objectForKey("type") as! Double
        self.deadline = dictionary.objectForKey("deadline") as! Double
        self.version = dictionary.objectForKey("version") as! Double
        self.signer = dictionary.objectForKey("signer") as! String
        
        return self
    }
}
