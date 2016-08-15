import UIKit

class _TransferTransaction: TransactionPostMetaData
{
    var amount :Double!
    var recipient :String!
    var message :MessageGetMetaData = MessageGetMetaData()
    
    override init() {
        super.init()
        
        type = transferTransaction
    }
    
    final override func getFrom(dictionary: NSDictionary) {
        if dictionary.objectForKey("signature") != nil {
            self.signature = dictionary.objectForKey("signature") as! String
        }
        
        self.timeStamp  = dictionary.objectForKey("timeStamp") as! Double
        self.amount = dictionary.objectForKey("amount")as! Double
        self.fee = dictionary.objectForKey("fee") as! Double
        self.recipient = dictionary.objectForKey("recipient") as! String
        self.type = dictionary.objectForKey("type") as! Int
        self.deadline = dictionary.objectForKey("deadline") as! Double

        let message : NSDictionary = dictionary.objectForKey("message") as! NSDictionary
        self.message.payload = (message.objectForKey("payload") as? String)?.asByteArray()
        self.message.type = message.objectForKey("type") as? Int ?? 0
        self.message.signer = dictionary.objectForKey("signer") as? String
        
        self.version = dictionary.objectForKey("version") as! Double
        self.signer = dictionary.objectForKey("signer") as! String
    }
}
