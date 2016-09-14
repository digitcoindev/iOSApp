import UIKit

class AggregateModificationTransaction: TransactionPostMetaData
{
    var modifications :[AccountModification] = [AccountModification]()
    var minCosignatory :Int!
    
    override init() {
        super.init()
        minCosignatory = 0
        type = multisigAggregateModificationTransaction
    }
    
    final func addModification(_ type :Int , publicKey :String) {
        if publicKey.utf16.count != 64 {
            print("ERROR. Modification receive public key with wrong length (length : \(publicKey.utf16.count / 2) bytes)")
        }
        
        var modification :AccountModification = AccountModification()
        modification.publicKey = publicKey
        modification.modificationType = type
        
        self.modifications.append(modification)
    }
    
    final override func getFrom(_ dictionary: NSDictionary) {
        self.timeStamp = dictionary.object(forKey: "timeStamp") as! Double
        self.deadline = dictionary.object(forKey: "deadline") as! Double
        self.version = dictionary.object(forKey: "version") as! Double
        self.signer = dictionary.object(forKey: "signer") as! String
        
        if dictionary.object(forKey: "signature") != nil {
            self.signature = dictionary.object(forKey: "signature") as! String
        }

        for modification in dictionary.object(forKey: "modifications") as! [NSDictionary] {
        self.addModification(modification.object(forKey: "modificationType") as! Int, publicKey: modification.object(forKey: "cosignatoryAccount") as! String)
        }
        
        self.fee = dictionary.object(forKey: "fee") as! Double
    }
}
