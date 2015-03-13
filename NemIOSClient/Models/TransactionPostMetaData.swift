import UIKit

class TransactionPostMetaData: NSObject
{
    var timeStamp :Double!
    var amount :Double!
    var fee :Double!
    var recipient :String!
    var type :Double!
    var deadline :Double!
    var message :MessageGetMetaData = MessageGetMetaData()
    var version :Double!
    var signer :String!
    var privateKey :String!
}
