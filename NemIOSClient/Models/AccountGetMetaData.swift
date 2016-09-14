import UIKit

class AccountGetMetaData: NSObject
{
    var address : String!
    var balance : Double!
    var importance : Double!
    var publicKey: String?
    var label : String?
    var vestedBalance :Double?
    var harvestedBlocks : Int!
    var cosignatories :[AccountGetMetaData] = [AccountGetMetaData]()
    var cosignatoryOf: [AccountGetMetaData] = [AccountGetMetaData]()
    var minCosignatories :Int? = nil
    var status : String!
    var remoteStatus : String!
    
    final func getFrom(_ dictionary :NSDictionary) -> AccountGetMetaData {
        let accountData :NSDictionary = dictionary.object(forKey: "account") as! NSDictionary
        let metaData :NSDictionary = dictionary.object(forKey: "meta") as! NSDictionary

        self.address = accountData.object(forKey: "address") as! String
        self.balance = accountData.object(forKey: "balance") as! Double
        self.vestedBalance = accountData.object(forKey: "vestedBalance") as? Double
        self.importance  = accountData.object(forKey: "importance") as! Double * 10000
        self.publicKey = accountData.object(forKey: "publicKey") as? String
        self.label = accountData.object(forKey: "label") as? String
        self.harvestedBlocks = accountData.object(forKey: "harvestedBlocks") as! Int
        self.status = metaData.object(forKey: "status") as! String
        self.remoteStatus = metaData.object(forKey: "remoteStatus") as! String
        
        let cosignatoryOfDic :[NSDictionary] = metaData.object(forKey: "cosignatoryOf") as! [NSDictionary]
        
        for accountDic in cosignatoryOfDic {
            self.cosignatoryOf.append(AccountGetMetaData().getCosignatory(accountDic))
        }
        
        let cosignatoriesDic :[NSDictionary] = metaData.object(forKey: "cosignatories") as! [NSDictionary]
        
        for cosignatoryDic in cosignatoriesDic {
            self.cosignatories.append(self.getCosignatory(cosignatoryDic))
        }
        
        if  self.cosignatories.count > 0 {
            self.minCosignatories = (accountData.object(forKey: "multisigInfo") as! NSDictionary).object(forKey: "minCosignatories") as? Int
        }
        
        return self
    }
    
    final func getCosignatory(_ dictionary :NSDictionary) -> AccountGetMetaData {
        let account = AccountGetMetaData()
        account.address = dictionary.object(forKey: "address") as! String
        account.balance = dictionary.object(forKey: "balance") as! Double
        account.importance  = dictionary.object(forKey: "importance") as! Double
        account.publicKey = dictionary.object(forKey: "publicKey") as? String
        account.label = dictionary.object(forKey: "label") as? String
        account.harvestedBlocks = dictionary.object(forKey: "harvestedBlocks") as! Int
        
        return account
    }
}
