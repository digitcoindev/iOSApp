import UIKit

class _MultisigTransaction: TransactionPostMetaData
{
    var innerTransaction : _TransactionPostMetaData!
    var signatures :[Signature] = [Signature]()
    override init() {
        super.init()
        
        type = multisigTransaction
    }
    
    final override func getFrom(dictionary: NSDictionary) {
        if dictionary.objectForKey("signature") != nil {
            self.signature = dictionary.objectForKey("signature") as! String
        }
        
        for dic in dictionary.objectForKey("signatures") as! [NSDictionary] {
            let sign :Signature = Signature().fromDictionary(dic)
            self.signatures.append(sign)
        }
        
        self.timeStamp  = dictionary.objectForKey("timeStamp") as! Double
        self.fee = dictionary.objectForKey("fee") as! Double
        self.type = dictionary.objectForKey("type") as! Int
        self.deadline = dictionary.objectForKey("deadline") as! Double
        self.version = dictionary.objectForKey("version") as! Double
        self.signer = dictionary.objectForKey("signer") as! String
        
        let innerDictionary :NSDictionary = dictionary.objectForKey("otherTrans") as! NSDictionary
         
        switch(innerDictionary.objectForKey("type") as! Int) {
            
        case transferTransaction:
            let transaction :TransferTransaction = TransferTransaction()
            transaction.id = self.id
            transaction.height = self.height
            transaction.hashString = self.hashString
            transaction.getFrom(innerDictionary)
            transaction.signature = self.signature
            self.innerTransaction = transaction
            
        case importanceTransaction:
            let transaction :ImportanceTransferTransaction = ImportanceTransferTransaction()
            transaction.id = self.id
            transaction.height = self.height
            transaction.hashString = self.hashString
            transaction.getFrom(innerDictionary)
            transaction.signature = self.signature
            self.innerTransaction = transaction
            
        case multisigAggregateModificationTransaction:
            let transaction :AggregateModificationTransaction = AggregateModificationTransaction()
            transaction.id = self.id
            transaction.height = self.height
            transaction.hashString = self.hashString
            transaction.getFrom(innerDictionary)
            transaction.signature = self.signature
            self.innerTransaction = transaction
            
        default:
            break
        }
    }
}