import UIKit

@objc protocol APIManagerDelegate
{
    optional func heartbeatResponceFromServer(server :Server ,successed :Bool)
    optional func accountGetResponceWithAccount(account :AccountGetMetaData?)
    optional func accountTransfersAllResponceWithTransactions(data :[TransactionPostMetaData]?)
    optional func unconfirmedTransactionsResponceWithTransactions(data :[TransactionPostMetaData]?)
}

class APIManager: NSObject
{
    private let _session = NSURLSession.sharedSession()
    private let _apiDipatchQueue :dispatch_queue_t = dispatch_queue_create("Api queu", nil)
    var delegate :AnyObject!
    
    override init() {
        super.init()
    }
    
    //URLSession
    
    func endSession() {
        _session.finishTasksAndInvalidate()
    }
    
    //API
    
    final func heartbeat(server :Server) {
        dispatch_async(_apiDipatchQueue,
            {
                () -> Void in
                
                var request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/heartbeat"))!)
                var err: NSError?
                
                request.HTTPMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                var task = self._session.dataTaskWithRequest(request, completionHandler: {
                    data, response, error -> Void in
                    
                    var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                    var err: NSError?
                    var layers = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                    
                    if(err != nil) {
                        println(err!.localizedDescription)
                        
                        
                        dispatch_async(dispatch_get_main_queue())
                            {
                                if self.delegate != nil && self.delegate!.respondsToSelector("heartbeatResponceFromServer:successed:") {
                                    (self.delegate as! APIManagerDelegate).heartbeatResponceFromServer!(server ,successed :false)
                                }
                        }
                        
                        println("NIS is not available!")
                    }
                    else {
                        var message :String = (layers! as NSDictionary).objectForKey("message") as! String
                        
                        println("\nRequest : /heartbeat")
                        
                        self.timeSynchronize(server)
                        
                        dispatch_async(dispatch_get_main_queue())
                            {
                                if self.delegate != nil && self.delegate!.respondsToSelector("heartbeatResponceFromServer:successed:") {
                                    (self.delegate as! APIManagerDelegate).heartbeatResponceFromServer!(server ,successed :true)
                                }
                        }
                    }
                })
                
                task.resume()
        })
    }
    
    final func accountGet(server :Server, account_address :String)  {
        dispatch_async(_apiDipatchQueue,
            {
                () -> Void in
                
                var request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/account/get?address=" + account_address))!)
                var err: NSError?
                
                request.HTTPMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                var task = self._session.dataTaskWithRequest(request, completionHandler: {
                    data, response, error -> Void in
                    
                    var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                    var err: NSError?
                    var layers = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                    if(err != nil) {
                        println(err!.localizedDescription)
                        
                        dispatch_async(dispatch_get_main_queue())
                            {
                                if self.delegate != nil && self.delegate!.respondsToSelector("accountGetResponceWithAccount:") {
                                    (self.delegate as! APIManagerDelegate).accountGetResponceWithAccount!(nil)
                                }
                        }
                    }
                    else if (layers! as NSDictionary).objectForKey("error")  == nil {
                        var requestData :AccountGetMetaData = AccountGetMetaData()
                        
                        requestData.getFrom(layers! as NSDictionary)
                        
                        dispatch_async(dispatch_get_main_queue())
                            {
                                if self.delegate != nil && self.delegate!.respondsToSelector("accountGetResponceWithAccount:") {
                                    (self.delegate as! APIManagerDelegate).accountGetResponceWithAccount!(requestData)
                                }
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue())
                            {
                                if self.delegate != nil && self.delegate!.respondsToSelector("accountGetResponceWithAccount:") {
                                    (self.delegate as! APIManagerDelegate).accountGetResponceWithAccount!(nil)
                                }
                        }
                    }
                })
                
                task.resume()
        })
    }
    
    final func accountTransfersAll(server :Server, account_address :String) {
        dispatch_async(_apiDipatchQueue,
            {
                () -> Void in

                var request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/account/transfers/all?address=" + account_address))!)
                var err: NSError?
                
                request.HTTPMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                var task = self._session.dataTaskWithRequest(request, completionHandler: {
                    data, response, error -> Void in
                    
                    var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                    var err: NSError?
                    var layers = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                    if(err != nil) {
                        println(err!.localizedDescription)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.delegate != nil && self.delegate!.respondsToSelector("accountTransfersAllResponceWithTransactions:") {
                                (self.delegate as! APIManagerDelegate).accountTransfersAllResponceWithTransactions!(nil)
                            }
                        }
                    }
                    else if (layers! as NSDictionary).objectForKey("error")  == nil {
                        var data :[NSDictionary] = (layers! as NSDictionary).objectForKey("data") as! [NSDictionary]
                        
                        var requestDataAll :[TransactionPostMetaData] = [TransactionPostMetaData]()
                        
                        for object in data
                        {
                            var meta :NSDictionary = object.objectForKey("meta") as! NSDictionary
                            var transaction :NSDictionary = object.objectForKey("transaction") as! NSDictionary
                            
                            switch(transaction.objectForKey("type") as! Int) {
                            case transferTransaction :
                                
                                var requestData :TransferTransaction = TransferTransaction()
                                
                                requestData.getBeginFrom(meta)
                                requestData.getFrom(transaction)
                                requestDataAll.append(requestData)
                                
                            case multisigAggregateModificationTransaction :
                                
                                var requestData :AggregateModificationTransaction = AggregateModificationTransaction()
                                
                                requestData.getBeginFrom(meta)
                                requestData.getFrom(transaction)
                                requestDataAll.append(requestData)
                                
                            case multisigTransaction :
                                
                                var requestData :MultisigTransaction = MultisigTransaction()
                                
                                requestData.getBeginFrom(meta)
                                requestData.getFrom(transaction)
                                requestDataAll.append(requestData)
                                
                            default :
                                break
                            }
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.delegate != nil && self.delegate!.respondsToSelector("accountTransfersAllResponceWithTransactions:") {
                                (self.delegate as! APIManagerDelegate).accountTransfersAllResponceWithTransactions!(requestDataAll)
                            }
                        }
                    }
                    else {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.delegate != nil && self.delegate!.respondsToSelector("accountTransfersAllResponceWithTransactions:") {
                                (self.delegate as! APIManagerDelegate).accountTransfersAllResponceWithTransactions!(nil)
                            }
                        }
                    }
                })
                
                task.resume()
            })
    }
    
    final func unconfirmedTransactions(server :Server, account_address :String) {

        dispatch_async(_apiDipatchQueue,
            {
                () -> Void in

                var request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/account/unconfirmedTransactions?address=" + account_address))!)
                var err: NSError?
                
                request.HTTPMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                var task = self._session.dataTaskWithRequest(request, completionHandler: {
                    data, response, error -> Void in
                    
                    var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                    var err: NSError?
                    var layers = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                    if(err != nil) {
                        println(err!.localizedDescription)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.delegate != nil && self.delegate!.respondsToSelector("unconfirmedTransactionsResponceWithTransactions:") {
                                (self.delegate as! APIManagerDelegate).unconfirmedTransactionsResponceWithTransactions!(nil)
                            }
                        }
                    }
                    else if (layers! as NSDictionary).objectForKey("error")  == nil {
                        var data :[NSDictionary] = (layers! as NSDictionary).objectForKey("data") as! [NSDictionary]
                        
                        var requestDataAll :[TransactionPostMetaData] = [TransactionPostMetaData]()
                        
                        println("\nRequest : /account/unconfirmedTransactions")
                        
                        for object in data {
                            var meta :NSDictionary = object.objectForKey("meta") as! NSDictionary
                            
                            var transaction :NSDictionary = object.objectForKey("transaction") as! NSDictionary
                            
                            switch(transaction.objectForKey("type") as! Int) {
                            case transferTransaction :
                                
                                var requestData :TransferTransaction = TransferTransaction()
                                
                                if  let metaData = meta.objectForKey("data") as? String
                                {
                                    requestData.data = metaData
                                }
                                
                                requestData.getFrom(transaction)
                                requestDataAll.append(requestData)
                                
                            case multisigAggregateModificationTransaction :
                                
                                var requestData :AggregateModificationTransaction = AggregateModificationTransaction()
                                
                                if  meta.objectForKey("data") != nil
                                {
                                    requestData.data = meta.objectForKey("data") as! String
                                }
                                
                                requestData.getFrom(transaction)
                                requestDataAll.append(requestData)
                                
                            case multisigTransaction :
                                
                                var requestData :MultisigTransaction = MultisigTransaction()
                                
                                if  meta.objectForKey("data") != nil
                                {
                                    requestData.data = meta.objectForKey("data") as! String
                                }
                                
                                requestData.getFrom(transaction)
                                requestDataAll.append(requestData)
                                
                            default :
                                break
                            }
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.delegate != nil && self.delegate!.respondsToSelector("unconfirmedTransactionsResponceWithTransactions:") {
                                (self.delegate as! APIManagerDelegate).unconfirmedTransactionsResponceWithTransactions!(requestDataAll)
                            }
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.delegate != nil && self.delegate!.respondsToSelector("unconfirmedTransactionsResponceWithTransactions:") {
                                (self.delegate as! APIManagerDelegate).unconfirmedTransactionsResponceWithTransactions!(nil)
                            }
                        }
                    }
                })
                
                task.resume()
            })
    }
    
    final func prepareAnnounce(server :Server, transaction :TransactionPostMetaData) {
        dispatch_async(_apiDipatchQueue,
            {
                () -> Void in

                var signedTransaction :SignedTransactionMetaData = SignManager.signTransaction(transaction)
                
                var request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/transaction/announce"))!)
                
                request.HTTPMethod = "POST"
                
                var params = ["data" : signedTransaction.dataT ,  "signature" : signedTransaction.signatureT ] as Dictionary<String, String>
                
                var err: NSError?
                var str = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
                
                request.HTTPBody = str
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                var task = self._session.dataTaskWithRequest(request, completionHandler: {           data, response, error -> Void in
                    var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                    var err: NSError?
                    var json  = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                    
                    if(err != nil) {
                        println(err!.localizedDescription)
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("prepareAnnounceDenied", object:nil)
                    }
                    else if (json! as NSDictionary).objectForKey("error")  == nil {
                        println(json)
                        NSNotificationCenter.defaultCenter().postNotificationName("prepareAnnounceSuccessed", object:json)
                        
                    }
                    else {
                        NSNotificationCenter.defaultCenter().postNotificationName("prepareAnnounceDenied", object:nil)
                    }
                })
                
                task.resume()
            })
    }
    
    final func timeSynchronize(server :Server) {
        dispatch_async(_apiDipatchQueue,
            {
                () -> Void in

                var request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/time-sync/network-time" ))!)
                var err: NSError?
                
                request.HTTPMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                var task = self._session.dataTaskWithRequest(request, completionHandler: {
                    data, response, error -> Void in
                    
                    var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                    var err: NSError?
                    var layers = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                    if(err != nil) {
                        println(err!.localizedDescription)
                    }
                    else {
                        var date  = (layers! as NSDictionary).objectForKey("sendTimeStamp") as! Double
                        
                        TimeSynchronizator.nemTime = date / 1000
                    }
                })
                
                task.resume()
            })
    }
    
}





