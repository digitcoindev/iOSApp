import UIKit

class APIManager: NSObject
{
    let session = NSURLSession.sharedSession()
    
    override init()
    {
        super.init()
    }
    
    //URLSession
    
    func endSession()
    {
        session.finishTasksAndInvalidate()
    }
    
    //API
    
    final func heartbeat(server :Server) -> Bool
    {
        var request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/heartbeat"))!)
        var err: NSError?
        
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler:
            {
                data, response, error -> Void in
                
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                var err: NSError?
                var layers = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                
                if(err != nil)
                {
                    println(err!.localizedDescription)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("heartbeatDenied", object:nil)
                    
                    println("NIS is not available!")
                }
                else
                {
                    var message :String = (layers! as NSDictionary).objectForKey("message") as! String
                    
                    println("\nRequest : /heartbeat")
                    
                    self.timeSynchronize(server)

                    NSNotificationCenter.defaultCenter().postNotificationName("heartbeatSuccessed", object:layers )
                }
        })
        
        task.resume()
        
        return true
    }
    
    final func testHeartbeat(server :Server) -> Bool
    {
        var request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/heartbeat"))!)
        var err: NSError?
        
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler:
            {
                data, response, error -> Void in
                
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                var err: NSError?
                var layers = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                if(err != nil)
                {
                    println(err!.localizedDescription)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("testHeartbeatDenied", object:nil)
                    
                    
                    println("NIS is not available!")
                }
                else
                {
                    var message :String = (layers! as NSDictionary).objectForKey("message") as! String
                    
                    println("\nRequest : /heartbeat")
                    
                    //println("\nSucces : \n\tCode : \(code)\n\tType : \(type)\n\tMessage : \(message)")
                    
                    self.timeSynchronize(server)
                    NSNotificationCenter.defaultCenter().postNotificationName("testHeartbeatSuccessed", object:layers )
                }
        })
        
        task.resume()
        
        return true
    }
    
    final func accountGet(server :Server, account_address :String) -> Bool
    {        
        var request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/account/get?address=" + account_address))!)
        var err: NSError?
        
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler:
            {
                data, response, error -> Void in
                
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                var err: NSError?
                var layers = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                if(err != nil)
                {
                    println(err!.localizedDescription)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("accountGetDenied", object:nil)
                    
                    
                    println("NIS is not available!")
                }
                else if (layers! as NSDictionary).objectForKey("error")  == nil
                {
                    var requestData :AccountGetMetaData = AccountGetMetaData()
                    
                    requestData.getFrom(layers! as NSDictionary)
                                        
                    println("\nRequest : /account/get")
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("accountGetSuccessed", object:requestData )
                }
                else
                {
                    NSNotificationCenter.defaultCenter().postNotificationName("accountGetDenied", object:nil)
                }
        })
        
        task.resume()

        return true
    }
    
    final func accountTransfersAll(server :Server, account_address :String) -> Bool
    {
        var request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/account/transfers/all?address=" + account_address))!)
        var err: NSError?
        
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler:
            {
                data, response, error -> Void in
                
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                var err: NSError?
                var layers = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                if(err != nil)
                {
                    println(err!.localizedDescription)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("accountTransfersAllDenied", object:nil)
                    
                    
                    println("NIS is not available!")
                }
                else if (layers! as NSDictionary).objectForKey("error")  == nil
                {
                    var data :[NSDictionary] = (layers! as NSDictionary).objectForKey("data") as! [NSDictionary]
                    
                    var requestDataAll :[TransactionPostMetaData] = [TransactionPostMetaData]()
                    
                    println("\nRequest : /account/transfers/all")
                    
                    for object in data
                    {
                        var meta :NSDictionary = object.objectForKey("meta") as! NSDictionary
                        var transaction :NSDictionary = object.objectForKey("transaction") as! NSDictionary
                        
                        switch(transaction.objectForKey("type") as! Int)
                        {
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
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("accountTransfersAllSuccessed", object:requestDataAll )
                    
                }
                else
                {
                    NSNotificationCenter.defaultCenter().postNotificationName("accountTransfersAllDenied", object:nil)
                }
        })
        
        task.resume()
        
        
        return true
    }
    
    final func unconfirmedTransactions(server :Server, account_address :String) -> Bool
    {
        var request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/account/unconfirmedTransactions?address=" + account_address))!)
        var err: NSError?
        
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler:
            {
                data, response, error -> Void in
                
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                var err: NSError?
                var layers = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                if(err != nil)
                {
                    println(err!.localizedDescription)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("accountTransfersAllDenied", object:nil)
                    
                    
                    println("NIS is not available!")
                }
                else if (layers! as NSDictionary).objectForKey("error")  == nil
                {
                    var data :[NSDictionary] = (layers! as NSDictionary).objectForKey("data") as! [NSDictionary]
                    
                    var requestDataAll :[TransactionPostMetaData] = [TransactionPostMetaData]()
                    
                    println("\nRequest : /account/unconfirmedTransactions")
                    
                    for object in data
                    {
                        var meta :NSDictionary = object.objectForKey("meta") as! NSDictionary
                        
                        var transaction :NSDictionary = object.objectForKey("transaction") as! NSDictionary
                        
                        switch(transaction.objectForKey("type") as! Int)
                        {
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
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("unconfirmedTransactionsSuccessed", object:requestDataAll )
                    
                }
                else
                {
                    NSNotificationCenter.defaultCenter().postNotificationName("accountTransfersAllDenied", object:nil)
                }
        })
        
        task.resume()
        
        
        return true
    }
    
    final func getBlockWithHeight(server :Server ,height :Int ) -> Bool
    {
        var request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/block/at/public"))!)       
        request.HTTPMethod = "POST"
        
        var params = ["height":height] as Dictionary<String, Int>
        var err: NSError?
        var str = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        request.HTTPBody = str
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler:
            {           data, response, error -> Void in
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                var err: NSError?
                var json :NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                
                if(err != nil)
                {
                    println(err!.localizedDescription)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("getBlockWithHeightDenied", object:nil)
                    
                    println("NIS is not available!")
                }
                else if (json! as NSDictionary).objectForKey("error")  == nil
                {
                    CoreDataManager().addBlock(height, timeStamp: (json!.objectForKey("timeStamp") as! Double) )
                    NSNotificationCenter.defaultCenter().postNotificationName("getBlockWithHeightSuccessed", object:nil)
                }
                else
                {
                    NSNotificationCenter.defaultCenter().postNotificationName("getBlockWithHeightDenied", object:nil)
                }
        })
        
        task.resume()
        
        return true
    }
    
    final func prepareAnnounce(server :Server, transaction :TransactionPostMetaData) -> Bool
    {

        var signedTransaction :SignedTransactionMetaData = SignManager.signTransaction(transaction)
        
        var request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/transaction/announce"))!)

        request.HTTPMethod = "POST"

        var params = ["data" : signedTransaction.dataT ,  "signature" : signedTransaction.signatureT ] as Dictionary<String, String>
        
        var err: NSError?
        var str = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        request.HTTPBody = str
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler:
            {           data, response, error -> Void in
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                var err: NSError?
                var json  = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                
                if(err != nil)
                {
                    println(err!.localizedDescription)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("prepareAnnounceDenied", object:nil)
                                    }
                else if (json! as NSDictionary).objectForKey("error")  == nil
                {
                    println(json)
                    NSNotificationCenter.defaultCenter().postNotificationName("prepareAnnounceSuccessed", object:json)

                }
                else
                {
                    NSNotificationCenter.defaultCenter().postNotificationName("prepareAnnounceDenied", object:nil)
                }
       })
        
        task.resume()
        return true
    }
    final func timeSynchronize(server :Server) -> Bool
    {
        
        var request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/time-sync/network-time" ))!)
        var err: NSError?
        
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler:
            {
                data, response, error -> Void in
                
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                var err: NSError?
                var layers = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                if(err != nil)
                {
                    println(err!.localizedDescription)
                }
                else
                {
                    var date  = (layers! as NSDictionary).objectForKey("sendTimeStamp") as! Double
                    
                    TimeSynchronizator.nemTime = date / 1000
                }
        })
        
        task.resume()
        
        
        return true
    }

}





