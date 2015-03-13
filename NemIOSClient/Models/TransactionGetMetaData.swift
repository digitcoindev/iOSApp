import UIKit

class TransactionGetMetaData: NSObject
{
    var id :Double!
    var height :Double!
    var timeStamp :Double!
    var amount :Double!
    var signature :String!
    var fee :Double!
    var recipient :String!
    var type :Double!
    var deadline :Double!
    var message :MessageGetMetaData = MessageGetMetaData()
    var version :Double!
    var signer :String!
}