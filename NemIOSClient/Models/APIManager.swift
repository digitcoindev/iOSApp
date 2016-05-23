//import UIKit

@objc protocol APIManagerDelegate
{
    optional func heartbeatResponceFromServer(server :Server ,successed :Bool)
    optional func accountGetResponceWithAccount(account :AccountGetMetaData?)
    optional func accountHarvestResponceWithBlocks(blocks :[BlockGetMetaData]?)
    optional func accountTransfersAllResponceWithTransactions(data :[TransactionPostMetaData]?)
    optional func unconfirmedTransactionsResponceWithTransactions(data :[TransactionPostMetaData]?)
    optional func prepareAnnounceResponceWithTransactions(data :[TransactionPostMetaData]?)
    optional func failWithError(message :String)
}

class APIManager: NSObject
{
    private let _session = NSURLSession.sharedSession()
    private let _apiDipatchQueue :dispatch_queue_t = dispatch_queue_create("Api queu", nil)
    
    var delegate :AnyObject!
    var timeOutIntervar = NSTimeInterval(10)
    
    override init() {
        super.init()
    }
    
    //URLSession
    
    func endSession() {
        _session.finishTasksAndInvalidate()
    }
    
    //API
    
    final func heartbeat(server :Server) {
        dispatch_async(_apiDipatchQueue, {
                () -> Void in
                
                let request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/heartbeat"))!)
                request.HTTPMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.timeoutInterval = self.timeOutIntervar / 2
                
                let task = self._session.dataTaskWithRequest(request, completionHandler: {
                    data, response, error -> Void in
                    
                    if(data == nil) {
                        
                        dispatch_async(dispatch_get_main_queue())
                            {
                                if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.heartbeatResponceFromServer(_:successed:))) {
                                    (self.delegate as! APIManagerDelegate).heartbeatResponceFromServer!(server ,successed :false)
                                }
                        }
                        
                        return
                    }
                    
                    let layers = (try? NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves)) as? NSDictionary
                    
                    if(layers == nil) {
                        
                        dispatch_async(dispatch_get_main_queue())
                            {
                                if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.heartbeatResponceFromServer(_:successed:))) {
                                    (self.delegate as! APIManagerDelegate).heartbeatResponceFromServer!(server ,successed :false)
                                }
                        }
                        
                        print("NIS is not available!")
                    }
                    else {
                        
                        self.timeSynchronize(server)
                        
                        dispatch_async(dispatch_get_main_queue())
                            {
                                if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.heartbeatResponceFromServer(_:successed:))) {
                                    (self.delegate as! APIManagerDelegate).heartbeatResponceFromServer!(server ,successed :true)
                                }
                        }
                    }
                })
                
                task.resume()
        })
    }
    
    final func accountGet(server :Server, account_address :String)  {
        dispatch_async(_apiDipatchQueue, {
                () -> Void in
                
                let request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/account/get?address=" + account_address))!)
            
                request.HTTPMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.timeoutInterval = self.timeOutIntervar
                
                let task = self._session.dataTaskWithRequest(request, completionHandler: {
                    data, response, error -> Void in
                    
                    if(data == nil) {
                        
                        dispatch_async(dispatch_get_main_queue())
                            {
                                if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.accountGetResponceWithAccount(_:))) {
                                    (self.delegate as! APIManagerDelegate).accountGetResponceWithAccount!(nil)
                                }
                        }
                        
                        return
                    }
                    
                    let layers = (try? NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves)) as? NSDictionary
                    if(layers == nil) {
                        
                        dispatch_async(dispatch_get_main_queue())
                            {
                                if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.accountGetResponceWithAccount(_:))) {
                                    (self.delegate as! APIManagerDelegate).accountGetResponceWithAccount!(nil)
                                }
                        }
                    }
                    else if (layers! as NSDictionary).objectForKey("error")  == nil {
                        let requestData :AccountGetMetaData = AccountGetMetaData()
                        
                        requestData.getFrom(layers! as NSDictionary)
                        
                        dispatch_async(dispatch_get_main_queue())
                            {
                                if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.accountGetResponceWithAccount(_:))) {
                                    (self.delegate as! APIManagerDelegate).accountGetResponceWithAccount!(requestData)
                                }
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue())
                            {
                                if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.accountGetResponceWithAccount(_:))) {
                                    (self.delegate as! APIManagerDelegate).accountGetResponceWithAccount!(nil)
                                }
                        }
                    }
                })
                
                task.resume()
        })
    }
    
    final func accountHarvests(server :Server, account_address :String)  {
        dispatch_async(_apiDipatchQueue, {
            () -> Void in
            
            let request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/account/harvests?address=" + account_address))!)
            
            request.HTTPMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.timeoutInterval = self.timeOutIntervar
            
            let task = self._session.dataTaskWithRequest(request, completionHandler: {
                data, response, error -> Void in
                
                if(data == nil) {
                    
                    dispatch_async(dispatch_get_main_queue())
                        {
                            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.accountHarvestResponceWithBlocks(_:))) {
                                (self.delegate as! APIManagerDelegate).accountHarvestResponceWithBlocks!(nil)
                            }
                    }
                    
                    return
                }
                
                let layers = (try? NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves)) as? NSDictionary
                if(layers == nil) {
                    
                    dispatch_async(dispatch_get_main_queue())
                        {
                            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.accountHarvestResponceWithBlocks(_:))) {
                                (self.delegate as! APIManagerDelegate).accountHarvestResponceWithBlocks!(nil)
                            }
                    }
                }
                else if (layers! as NSDictionary).objectForKey("error")  == nil {
                    var blocks :[BlockGetMetaData] = []
                    
                    for blockDic in layers?.objectForKey("data") as! [NSDictionary] {
                        let block :BlockGetMetaData = BlockGetMetaData()
                        block.getFrom(blockDic)
                        blocks.append(block)
                    }
                    
                    dispatch_async(dispatch_get_main_queue())
                        {
                            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.accountHarvestResponceWithBlocks(_:))) {
                                (self.delegate as! APIManagerDelegate).accountHarvestResponceWithBlocks!(blocks)
                            }
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue())
                        {
                            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.accountHarvestResponceWithBlocks(_:))) {
                                (self.delegate as! APIManagerDelegate).accountHarvestResponceWithBlocks!(nil)
                            }
                    }
                }
            })
            
            task.resume()
        })
    }
    
    final func accountTransfersAll(server :Server, account_address :String, aditional :String = "") {
        dispatch_async(_apiDipatchQueue, {
                () -> Void in

                let request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/account/transfers/all?address=" + account_address + aditional))!)
            
                request.HTTPMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.timeoutInterval = self.timeOutIntervar
                
                let task = self._session.dataTaskWithRequest(request, completionHandler: {
                    data, response, error -> Void in
                    error?.localizedDescription
                    if(data == nil) {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.accountTransfersAllResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).accountTransfersAllResponceWithTransactions!(nil)
                            }
                        }
                        
                        return
                    }
                    
                    let layers = (try? NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves)) as? NSDictionary
                    if(layers == nil) {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.accountTransfersAllResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).accountTransfersAllResponceWithTransactions!(nil)
                            }
                        }
                    }
                    else if (layers! as NSDictionary).objectForKey("error")  == nil {
                        let data :[NSDictionary] = (layers! as NSDictionary).objectForKey("data") as! [NSDictionary]
                        
                        var requestDataAll :[TransactionPostMetaData] = [TransactionPostMetaData]()
                        
                        for object in data
                        {
                            let meta :NSDictionary = object.objectForKey("meta") as! NSDictionary
                            let transaction :NSDictionary = object.objectForKey("transaction") as! NSDictionary
                            
                            switch(transaction.objectForKey("type") as! Int) {
                            case transferTransaction :
                                
                                let requestData :TransferTransaction = TransferTransaction()
                                
                                requestData.getBeginFrom(meta)
                                requestData.getFrom(transaction)
                                requestDataAll.append(requestData)
                                
                            case multisigAggregateModificationTransaction :
                                
                                let requestData :AggregateModificationTransaction = AggregateModificationTransaction()
                                
                                requestData.getBeginFrom(meta)
                                requestData.getFrom(transaction)
                                requestDataAll.append(requestData)
                                
                            case multisigTransaction :
                                
                                let requestData :MultisigTransaction = MultisigTransaction()
                                
                                requestData.getBeginFrom(meta)
                                requestData.getFrom(transaction)
                                requestDataAll.append(requestData)
                                
                            default :
                                break
                            }
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.accountTransfersAllResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).accountTransfersAllResponceWithTransactions!(requestDataAll)
                            }
                        }
                    }
                    else {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.accountTransfersAllResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).accountTransfersAllResponceWithTransactions!(nil)
                            }
                        }
                    }
                })
                
                task.resume()
            })
    }
    
    final func unconfirmedTransactions(server :Server, account_address :String) {

        dispatch_async(_apiDipatchQueue, {
                () -> Void in

                let request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/account/unconfirmedTransactions?address=" + account_address))!)
            
                request.HTTPMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.timeoutInterval = self.timeOutIntervar
                
                let task = self._session.dataTaskWithRequest(request, completionHandler: {
                    data, response, error -> Void in
                    
                    if(data == nil) {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.unconfirmedTransactionsResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).unconfirmedTransactionsResponceWithTransactions!(nil)
                            }
                        }
                        
                        return
                    }
                    
                    let layers = (try? NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves)) as? NSDictionary
                    if(layers == nil) {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.unconfirmedTransactionsResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).unconfirmedTransactionsResponceWithTransactions!(nil)
                            }
                        }
                    }
                    else if (layers! as NSDictionary).objectForKey("error")  == nil {
                        let data :[NSDictionary] = (layers! as NSDictionary).objectForKey("data") as! [NSDictionary]
                        
                        var requestDataAll :[TransactionPostMetaData] = [TransactionPostMetaData]()
                        
                        print("\nRequest : /account/unconfirmedTransactions")
                        
                        for object in data {
                            let meta :NSDictionary = object.objectForKey("meta") as! NSDictionary
                            
                            let transaction :NSDictionary = object.objectForKey("transaction") as! NSDictionary
                            
                            switch(transaction.objectForKey("type") as! Int) {
                            case transferTransaction :
                                
                                let requestData :TransferTransaction = TransferTransaction()
                                
                                if  let metaData = meta.objectForKey("data") as? String
                                {
                                    requestData.data = metaData
                                }
                                
                                requestData.getFrom(transaction)
                                requestDataAll.append(requestData)
                                
                            case multisigAggregateModificationTransaction :
                                
                                let requestData :AggregateModificationTransaction = AggregateModificationTransaction()
                                
                                if  meta.objectForKey("data") != nil
                                {
                                    requestData.data = meta.objectForKey("data") as! String
                                }
                                
                                requestData.getFrom(transaction)
                                requestDataAll.append(requestData)
                                
                            case multisigTransaction :
                                
                                let requestData :MultisigTransaction = MultisigTransaction()
                                
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
                            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.unconfirmedTransactionsResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).unconfirmedTransactionsResponceWithTransactions!(requestDataAll)
                            }
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.unconfirmedTransactionsResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).unconfirmedTransactionsResponceWithTransactions!(nil)
                            }
                        }
                    }
                })
                
                task.resume()
            })
    }
    
    final func prepareAnnounce(server :Server, transaction :TransactionPostMetaData) {
        dispatch_async(_apiDipatchQueue, {
                () -> Void in

                let signedTransaction :SignedTransactionMetaData = SignManager.signTransaction(transaction)
                
                let request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/transaction/announce"))!)
                
                request.HTTPMethod = "POST"
                
                let params = ["data" : signedTransaction.dataT ,  "signature" : signedTransaction.signatureT ] as Dictionary<String, String>
                
                var str: NSData?
                do {
                    str = try NSJSONSerialization.dataWithJSONObject(params, options: [])
                } catch  {
                    str = nil
                }
                
                request.HTTPBody = str
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.timeoutInterval = self.timeOutIntervar

            let task = self._session.dataTaskWithRequest(request, completionHandler: {
                    data, response, error -> Void in
                    
                    if(data == nil) {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.prepareAnnounceResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).prepareAnnounceResponceWithTransactions!(nil)
                            }
                        }
                        
                        return
                    }
                    
                    let layers = (try? NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves)) as? NSDictionary
                    if(layers == nil) {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.prepareAnnounceResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).prepareAnnounceResponceWithTransactions!(nil)
                            }
                        }
                    }
                    else if (layers! as NSDictionary).objectForKey("error")  == nil {

                        let message :String = (layers! as NSDictionary).objectForKey("message") as! String
                        
                        if message == "SUCCESS" {
                            dispatch_async(dispatch_get_main_queue()) {
                                if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.prepareAnnounceResponceWithTransactions(_:))) {
                                    (self.delegate as! APIManagerDelegate).prepareAnnounceResponceWithTransactions!([transaction])
                                }
                            }
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue()) {
                                if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.prepareAnnounceResponceWithTransactions(_:))) {
                                    (self.delegate as! APIManagerDelegate).prepareAnnounceResponceWithTransactions!([])
                                    (self.delegate as! APIManagerDelegate).failWithError?(message)
                                }
                            }
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(APIManagerDelegate.prepareAnnounceResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).prepareAnnounceResponceWithTransactions!(nil)
                            }
                        }
                    }
                })
                
                task.resume()
            })
    }
    
    final func timeSynchronize(server :Server) {
        dispatch_async(_apiDipatchQueue, {
                () -> Void in

                let request = NSMutableURLRequest(URL: NSURL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/time-sync/network-time" ))!)
            
                request.HTTPMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.timeoutInterval = self.timeOutIntervar
                
                let task = self._session.dataTaskWithRequest(request, completionHandler: {
                    data, response, error -> Void in
                    
                    guard let data = data else {
                        return
                    }
                    
                    let layers = (try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves)) as? NSDictionary
                    if(layers != nil) {
                        let date  = (layers! as NSDictionary).objectForKey("receiveTimeStamp") as! Double
                        
                        TimeSynchronizator.nemTime = date / 1000
                    }
                })
                
                task.resume()
            })
    }
    
    func downloadImage(url: NSURL, responce: ((image: UIImage) -> Void)){
        print("Started downloading \"\(url.URLByDeletingPathExtension!.lastPathComponent!)\".")
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                print("Finished downloading \"\(url.URLByDeletingPathExtension!.lastPathComponent!)\".")
                guard let image = UIImage(data: data) else { return }
                responce(image: image)
            }
        }
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
}





