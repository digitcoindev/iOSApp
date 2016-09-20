import UIKit

class _TransferTransaction: TransactionPostMetaData
{
    var amount :Double!
    var recipient :String!
//    var message :MessageGetMetaData = MessageGetMetaData()
    
    override init() {
        super.init()
        
        type = transferTransaction
    }
    
    final override func getFrom(_ dictionary: NSDictionary) {
        if dictionary.object(forKey: "signature") != nil {
            self.signature = dictionary.object(forKey: "signature") as! String
        }
        
        self.timeStamp  = dictionary.object(forKey: "timeStamp") as! Double
        self.amount = dictionary.object(forKey: "amount")as! Double
        self.fee = dictionary.object(forKey: "fee") as! Double
        self.recipient = dictionary.object(forKey: "recipient") as! String
        self.type = dictionary.object(forKey: "type") as! Int
        self.deadline = dictionary.object(forKey: "deadline") as! Double

//        let message : NSDictionary = dictionary.object(forKey: "message") as! NSDictionary
//        self.message.payload = (message.object(forKey: "payload") as? String)?.asByteArray()
//        self.message.type = message.object(forKey: "type") as? Int ?? 0
//        self.message.signer = dictionary.object(forKey: "signer") as? String
        
        self.version = dictionary.object(forKey: "version") as! Double
        self.signer = dictionary.object(forKey: "signer") as! String
    }
}
