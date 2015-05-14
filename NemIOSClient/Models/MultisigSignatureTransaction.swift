import UIKit

class MultisigSignatureTransaction: TransactionPostMetaData
{
    var lengthOfHashObject :Int = 36
    var lengthOfMultisigAccout :Int = 40
    var lengthOfHash :Int = 32
    var transactionHash :String!
    var multisigAccountAddress :String!
    
    
    override init()
    {
        super.init()
        
        type = multisigSignatureTransaction
    }
    
    final override func getFrom(dictionary: NSDictionary)
    {
        
    }
}
