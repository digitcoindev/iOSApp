import UIKit

class TransferTransaction: TransactionPostMetaData
{
    var amount :Double!
    var recipient :String!
    var message :MessageGetMetaData = MessageGetMetaData()
    
    override init()
    {
        super.init()
        
        type = transferTransaction
    }
    
    final override func getFrom(dictionary: NSDictionary)
    {
        if dictionary.objectForKey("signature") != nil
        {
            self.signature = dictionary.objectForKey("signature") as! String
        }
        
        self.timeStamp  = dictionary.objectForKey("timeStamp") as! Double
        self.amount = dictionary.objectForKey("amount")as! Double
        self.fee = dictionary.objectForKey("fee") as! Double
        self.recipient = dictionary.objectForKey("recipient") as! String
        self.type = dictionary.objectForKey("type") as! Int
        self.deadline = dictionary.objectForKey("deadline") as! Double

        var message : NSDictionary = dictionary.objectForKey("message") as! NSDictionary
        
        if message.objectForKey("payload") != nil
        {
            self.message.payload = (message.objectForKey("payload") as! String).stringFromHexadecimalStringUsingEncoding(NSUTF8StringEncoding)
            self.message.type = message.objectForKey("type") as! Double
        }
        else
        {
            self.message.payload = ""
            self.message.type = 0
        }
        
        self.version = dictionary.objectForKey("version") as! Double
        self.signer = dictionary.objectForKey("signer") as! String
    }
}
