import UIKit

class _MultisigTransaction: TransactionPostMetaData
{
    var innerTransaction : TransactionPostMetaData!
    var signatures :[Signature] = [Signature]()
    override init() {
        super.init()
        
        type = multisigTransaction
    }
    
    final override func getFrom(_ dictionary: NSDictionary) {
        if dictionary.object(forKey: "signature") != nil {
            self.signature = dictionary.object(forKey: "signature") as! String
        }
        
        for dic in dictionary.object(forKey: "signatures") as! [NSDictionary] {
            let sign :Signature = Signature().fromDictionary(dic)
            self.signatures.append(sign)
        }
        
        self.timeStamp  = dictionary.object(forKey: "timeStamp") as! Double
        self.fee = dictionary.object(forKey: "fee") as! Double
        self.type = dictionary.object(forKey: "type") as! Int
        self.deadline = dictionary.object(forKey: "deadline") as! Double
        self.version = dictionary.object(forKey: "version") as! Double
        self.signer = dictionary.object(forKey: "signer") as! String
        
        let innerDictionary :NSDictionary = dictionary.object(forKey: "otherTrans") as! NSDictionary
         
        switch(innerDictionary.object(forKey: "type") as! Int) {
            
        case transferTransaction:
            let transaction :_TransferTransaction = _TransferTransaction()
            transaction.id = self.id
            transaction.height = self.height
            transaction.hashString = self.hashString
            transaction.getFrom(innerDictionary)
            transaction.signature = self.signature
            self.innerTransaction = transaction
            
        case importanceTransaction:
            let transaction :_ImportanceTransferTransaction = _ImportanceTransferTransaction()
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
