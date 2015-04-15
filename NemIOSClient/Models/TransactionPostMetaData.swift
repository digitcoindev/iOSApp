import UIKit

class TransactionPostMetaData
{
    var id :Double!
    var height :Double!
    var hash :String!
    var signature :String!
    
    var type :Int = 0
    var version :Double!
    var timeStamp :Double!
    var privateKey :String!
    var signer :String!
    var fee :Double!
    var deadline :Double!
    var publicKeys :[String] = [String]()
    
    init()
    {
        
    }
}
