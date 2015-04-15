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
}
