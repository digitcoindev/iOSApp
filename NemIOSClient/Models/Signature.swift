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

    final func fromDictionary(_ dictionary :NSDictionary) -> Signature {
        self.timeStamp = dictionary.object(forKey: "timeStamp") as! Double
        self.otherHash = (dictionary.object(forKey: "otherHash") as! NSDictionary).object(forKey: "data") as! String
        self.otherAccount = dictionary.object(forKey: "otherAccount") as! String
        self.signature = dictionary.object(forKey: "signature") as! String
        self.fee = dictionary.object(forKey: "fee") as! Double
        self.type = dictionary.object(forKey: "type") as! Double
        self.deadline = dictionary.object(forKey: "deadline") as! Double
        self.version = dictionary.object(forKey: "version") as! Double
        self.signer = dictionary.object(forKey: "signer") as! String
        
        return self
    }
}
