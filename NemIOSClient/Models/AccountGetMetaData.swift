import UIKit

class AccountGetMetaData: NSObject
{
    var address : String!
    var balance : Double!
    var importance : Double!
    var publicKey: String?
    var label : String?
    var harvestedBlocks : Double!
    var cosignatories :[AccountGetMetaData] = [AccountGetMetaData]()
    var cosignatoryOf: [AccountGetMetaData] = [AccountGetMetaData]()
    var minCosignatories :Int? = nil
    var status : String!
    var remoteStatus : String!
    
    final func getFrom(dictionary :NSDictionary) -> AccountGetMetaData {
        let accountData :NSDictionary = dictionary.objectForKey("account") as! NSDictionary
        let metaData :NSDictionary = dictionary.objectForKey("meta") as! NSDictionary

        self.address = accountData.objectForKey("address") as! String
        self.balance = accountData.objectForKey("balance") as! Double
        self.importance  = accountData.objectForKey("importance") as! Double * 10000
        self.publicKey = accountData.objectForKey("publicKey") as? String
        self.label = accountData.objectForKey("label") as? String
        self.harvestedBlocks = accountData.objectForKey("harvestedBlocks") as! Double
        self.status = metaData.objectForKey("status") as! String
        self.remoteStatus = metaData.objectForKey("remoteStatus") as! String
        
        let cosignatoryOfDic :[NSDictionary] = metaData.objectForKey("cosignatoryOf") as! [NSDictionary]
        
        for accountDic in cosignatoryOfDic {
            self.cosignatoryOf.append(AccountGetMetaData().getCosignatory(accountDic))
        }
        
        let cosignatoriesDic :[NSDictionary] = metaData.objectForKey("cosignatories") as! [NSDictionary]
        
        for cosignatoryDic in cosignatoriesDic {
            self.cosignatories.append(self.getCosignatory(cosignatoryDic))
        }
        
        if  self.cosignatories.count > 0 {
            self.minCosignatories = (accountData.objectForKey("multisigInfo") as! NSDictionary).objectForKey("minCosignatories") as? Int
        }
        
        return self
    }
    
    final func getCosignatory(dictionary :NSDictionary) -> AccountGetMetaData {
        let account = AccountGetMetaData()
        account.address = dictionary.objectForKey("address") as! String
        account.balance = dictionary.objectForKey("balance") as! Double
        account.importance  = dictionary.objectForKey("importance") as! Double
        account.publicKey = dictionary.objectForKey("publicKey") as! String
        account.label = dictionary.objectForKey("label") as? String
        account.harvestedBlocks = dictionary.objectForKey("harvestedBlocks") as! Double
        
        return account
    }
}
