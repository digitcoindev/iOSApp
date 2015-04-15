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
                    var message :String = (layers! as NSDictionary).objectForKey("message") as String
                    var code :Int = (layers! as NSDictionary).objectForKey("code") as Int
                    var type :Int = (layers! as NSDictionary).objectForKey("type") as Int
                    
                    println("\nRequest : /heartbeat")

                    println("\nSucces : \n\tCode : \(code)\n\tType : \(type)\n\tMessage : \(message)")
                    
                    self.timeSynchronize(server)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("heartbeatSuccessed", object:layers )
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
                else
                {
                    var accountData :NSDictionary = (layers! as NSDictionary).objectForKey("account") as NSDictionary
                    var metaData :NSDictionary = (layers! as NSDictionary).objectForKey("meta") as NSDictionary
                    
                    var requestData :AccountGetMetaData = AccountGetMetaData()
                    
                    requestData.address = accountData.objectForKey("address") as String
                    requestData.balance = accountData.objectForKey("balance") as Double
                    requestData.importance  = accountData.objectForKey("importance") as Double
                    requestData.publicKey = accountData.objectForKey("publicKey")
                    requestData.label = accountData.objectForKey("label")
                    requestData.harvestedBlocks = accountData.objectForKey("harvestedBlocks") as Double
                    requestData.cosignatoryOf = metaData.objectForKey("cosignatoryOf")
                    requestData.status = metaData.objectForKey("status") as String
                    requestData.remoteStatus = metaData.objectForKey("remoteStatus") as String
                    
                    println("\nRequest : /account/get")

                    println("\nSucces :\n\t address : \(requestData.address)\n\t balance : \(requestData.balance)\n\t importance : \(requestData.importance)\n\t publicKey : \(requestData.publicKey!)\n\t label : \(requestData.label!)\n\t harvestedBlocks : \(requestData.harvestedBlocks)\n\t cosignatoryOf : \(requestData.cosignatoryOf!)\n\t status : \(requestData.status)\n\t remoteStatus : \(requestData.remoteStatus)")
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("accountGetSuccessed", object:requestData )
                    
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
                else
                {
                    var data :[NSDictionary] = (layers! as NSDictionary).objectForKey("data") as [NSDictionary]
                    
                    var requestDataAll :[TransactionPostMetaData] = [TransactionPostMetaData]()
                    
                    println("\nRequest : /account/transfers/all")
                    
                    for object in data
                    {
                        var meta :NSDictionary = object.objectForKey("meta") as NSDictionary
                        var transaction :NSDictionary = object.objectForKey("transaction") as NSDictionary
                        
                        switch(transaction.objectForKey("type") as Int)
                        {
                        case transferTransaction :
                            
                            var requestData :TransferTransaction = TransferTransaction()
                            
                            requestData.id = meta.objectForKey("id") as Double
                            requestData.signature = transaction.objectForKey("signature") as String
                            requestData.height = meta.objectForKey("height") as Double
                            requestData.hash = meta.objectForKey("hash")!.objectForKey("data") as String

                            requestData.timeStamp  = transaction.objectForKey("timeStamp") as Double
                            requestData.amount = transaction.objectForKey("amount")as Double
                            requestData.fee = transaction.objectForKey("fee") as Double
                            requestData.recipient = transaction.objectForKey("recipient") as String
                            requestData.type = transaction.objectForKey("type") as Int
                            requestData.deadline = transaction.objectForKey("deadline") as Double

                            var message : NSDictionary = transaction.objectForKey("message") as NSDictionary
                            
                            if message.objectForKey("payload") != nil
                            {
                                requestData.message.payload = (message.objectForKey("payload") as String).stringFromHexadecimalStringUsingEncoding(NSUTF8StringEncoding)
                                requestData.message.type = message.objectForKey("type") as Double
                            }
                            else
                            {
                                requestData.message.payload = ""
                                requestData.message.type = 0
                            }
                            
                            requestData.version = transaction.objectForKey("version") as Double
                            requestData.signer = transaction.objectForKey("signer") as String
                            
                            requestDataAll.append(requestData)
                            
                            println("\nSucces :\n\t id : \(requestData.id)\n\t height : \(requestData.height)\n\t timeStamp : \(requestData.timeStamp)\n\t amount : \(requestData.amount)\n\t signature : \(requestData.signature)\n\t fee : \(requestData.fee)\n\t recipient : \(requestData.recipient)\n\t type : \(requestData.type)\n\t deadline : \(requestData.deadline)\n\t payload : \(requestData.message.payload)\n\t id : \(requestData.message.type)\n\t version : \(requestData.version)\n\t signer : \(requestData.signer)")
                            
                        case multisigAggregateModificationTransaction :
                            
                            var requestData :AggregateModificationTransaction = AggregateModificationTransaction()
                            
                            requestData.id = meta.objectForKey("id") as Double
                            requestData.signature = transaction.objectForKey("signature") as String
                            requestData.height = meta.objectForKey("height") as Double
                            requestData.hash = meta.objectForKey("hash")!.objectForKey("data") as String
                            
                            requestData.timeStamp = transaction.objectForKey("timeStamp") as Double
                            requestData.deadline = transaction.objectForKey("deadline") as Double
                            requestData.version = transaction.objectForKey("version") as Double
                            requestData.signer = transaction.objectForKey("signer") as String
                            
                            for modification in transaction.objectForKey("modifications") as [NSDictionary]
                            {
                                requestData.addModification(modification.objectForKey("modificationType") as Int, publicKey: modification.objectForKey("cosignatoryAccount") as String)
                            }
                            
                            requestData.fee = transaction.objectForKey("fee") as Double
                            
                            println("\nSucces :")
                            println("\tid : \(requestData.id)")
                            println("\tsignature : \(requestData.signature)")
                            println("\theight : \(requestData.height)")
                            println("\thash : \(requestData.hash)")
                            println("\ttimeStamp : \(requestData.timeStamp)")
                            println("\tdeadline : \(requestData.deadline)")
                            println("\tversion : \(requestData.version)")
                            println("\tsigner : \(requestData.signer)")
                            
                            for mod :AccountModification in requestData.modifications
                            {
                                if (mod.modificationType == 1)
                                {
                                    println("\tmodification (add) : \(mod.publicKey)")
                                }
                                else
                                {
                                    println("\tmodification (delete) : \(mod.publicKey)")
                                }
                            }
                            
                        default :
                            break
                        }
                    }
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("accountTransfersAllSuccessed", object:requestDataAll )
                    
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
                else
                {
                    CoreDataManager().addBlock(height, timeStamp: (json!.objectForKey("timeStamp") as Double) )
                    NSNotificationCenter.defaultCenter().postNotificationName("getBlockWithHeightSuccessed", object:nil)
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
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("accountGetDenied", object:nil)
                    
                   println("NIS is not available!")
                }
                else
                {
                    println(json)
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
                    var date  = (layers! as NSDictionary).objectForKey("sendTimeStamp") as Double
                    
                    TimeSynchronizator.nemTime = date / 1000
                }
        })
        
        task.resume()
        
        
        return true
    }

}

//    {
//        "meta":
//            {
//                "id":49835,
//                "hash":
//                    {
//                        "data":"3a8576505c90aee97c4f4c128c40d56191f97eed71062331ae2089f7b24bf64a"
//                    },
//                "height":12259
//            },
//        "transaction":
//            {
//                "timeStamp":1080799,
//                "signature":"57015ac62ccd7ffb1d05969e1e34591097796236f9ea4f4c2a45ebbf64d5d54f36ff918d11e713fcb65db15640e606d0cb42bb59275ba7d5533f2416e12b110b",
//                "fee":100000000,
//                "type":4097,"deadline":1086199,
//                "version":-1744830463,
//                "signer":"dd13a7d3eec54e859617093f8221ab22357c9925ecdacd3321c7bc07148f9f67",
//                "modifications":
//                [
//                    {
//                        "modificationType":1,
//                        "cosignatoryAccount":"86af1de95090b7455172c8edcdef909f26d5f35d4ba3830acf23001b4037df6e"
//                    },
//                    {
//                        "modificationType":1,
//                        "cosignatoryAccount":"3e552f2abd457ac831b003de0ff8517d7c933a63f87c618227a5b664fd6ff8e6"
//                    }
//                ]
//            }
//    }









