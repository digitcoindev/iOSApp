import UIKit

class _ImportanceTransferTransaction: TransactionPostMetaData
{
    var lengthOfRemoutPublicKey :Int = 32
    var remoutPublicKey :String!
    var mode :Int!
    
    
    override init() {
        super.init()
        
        type = importanceTransaction
    }
    
    final override func getFrom(_ dictionary: NSDictionary) {
        
    }
}
