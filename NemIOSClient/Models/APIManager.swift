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
                    
                    var requestDataAll :[TransactionGetMetaData] = [TransactionGetMetaData]()
                    
                    println("\nRequest : /account/transfers/all")
                    
                    for object in data
                    {
                        var meta :NSDictionary = object.objectForKey("meta") as NSDictionary
                        var transaction :NSDictionary = object.objectForKey("transaction") as NSDictionary
                        
                        var requestData :TransactionGetMetaData = TransactionGetMetaData()
                        
                        requestData.id = meta.objectForKey("id") as Double
                        requestData.height = meta.objectForKey("height") as Double
                        requestData.timeStamp  = transaction.objectForKey("timeStamp") as Double
                        requestData.amount = transaction.objectForKey("amount")as Double
                        requestData.signature = transaction.objectForKey("signature") as String
                        requestData.fee = transaction.objectForKey("fee") as Double
                        requestData.recipient = transaction.objectForKey("recipient") as String
                        requestData.type = transaction.objectForKey("type") as Double
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
                        
                    }
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("accountTransfersAllSuccessed", object:requestDataAll )
                    
                }
        })
        
        task.resume()
        
        
        return true
    }
    
    final func prepareAnnounce(server :Server, transaction :TransactionPostMetaData, account_address :String) -> Bool
    {
        var request = NSMutableURLRequest(URL: NSURL(string: "http://httpbin.org/post")!)
        request.HTTPMethod = "POST"
        
        var messageDic :Dictionary = ["payload" : transaction.message.payload as  String, "type" : transaction.message.type ] as Dictionary <String, AnyObject>
        var transactionDic :Dictionary = ["timeStamp" : transaction.timeStamp,"amount" : transaction.amount,"fee" : transaction.fee,"recipient" : transaction.recipient,"type" : transaction.type,"deadline" : transaction.deadline,"message" : messageDic ,"version" : transaction.version,"signer" : transaction.signer] as Dictionary<String, AnyObject>
        var privateKeyDic :Dictionary = ["value":transaction.privateKey] as Dictionary<String, String>
        
        var params = ["transaction" : transactionDic ,  "privateKey" : privateKeyDic ] as Dictionary<String, AnyObject>
        
        var err: NSError?
        var str = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        println(str)
        
        request.HTTPBody = str
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler:
            {           data, response, error -> Void in
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                var err: NSError?
                var json  = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                //var result :NSDictionary = (json! as NSDictionary).objectForKey("json") as NSDictionary
                
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
    
    final func post() -> Bool
    {
        var request = NSMutableURLRequest(URL: NSURL(string: "http://127.0.0.1:7890//block/at/public")!)
        request.HTTPMethod = "POST"
        
        var params = ["height":53824] as Dictionary<String, Int>
        
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
                var result :NSDictionary = (json! as NSDictionary).objectForKey("json") as NSDictionary
                
                if(err != nil)
                {
                    println(err!.localizedDescription)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("accountGetDenied", object:nil)
                    
                    println("NIS is not available!")
                }
                else
                {
                    
                }
        })
        
        task.resume()
        
        return true
    }
}



//{
//    "transaction":
//    {
//        "timeStamp": 9111526,
//        "amount": 1000000000,
//        "fee": 3000000,
//        "recipient": "TDGIMREMR5NSRFUOMPI5OOHLDATCABNPC5ID2SVA",
//        "type": 257,
//        "deadline": 9154726,
//        "message":
//        {
//            "payload": "74657374207472616e73616374696f6e",
//            "type": 1
//        },
//        "version": 1,
//        "signer": "a1aaca6c17a24252e674d155713cdf55996ad00175be4af02a20c67b59f9fe8a"
//    },
//    "privateKey":
//    {
//        "value": "68e4f79f886927de698df4f857de2aada41ccca6617e56bb0d61623b35b08cc0",
//    }
//}