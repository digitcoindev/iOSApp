import UIKit

class AggregateModificationTransaction: TransactionPostMetaData
{
    var modifications :[AccountModification] = [AccountModification]()
    
    override init()
    {
        super.init()
     
        type = multisigAggregateModificationTransaction
    }
    
    final func addModification(type :Int , publicKey :String)
    {
        if publicKey.utf16Count != 64
        {
            println("ERROR. Modification receive public key with wrong length (length : \(publicKey.utf16Count / 2) bytes)")
        }
        
        var modification :AccountModification = AccountModification()
        modification.publicKey = publicKey
        modification.modificationType = type
        
        self.modifications.append(modification)
    }
}
