import UIKit

@objc protocol APIManagerDelegate
{
    @objc optional func heartbeatResponceFromServer(_ server :Server ,successed :Bool)
    @objc optional func accountGetResponceWithAccount(_ account :AccountGetMetaData?)
    @objc optional func accountHarvestResponceWithBlocks(_ blocks :[BlockGetMetaData]?)
    @objc optional func accountTransfersAllResponceWithTransactions(_ data :[TransactionPostMetaData]?)
    @objc optional func unconfirmedTransactionsResponceWithTransactions(_ data :[TransactionPostMetaData]?)
    @objc optional func prepareAnnounceResponceWithTransactions(_ data :[TransactionPostMetaData]?)
    @objc optional func failWithError(_ message :String)
}

class APIManager: NSObject
{
    fileprivate let _session = URLSession.shared
    fileprivate let _apiDipatchQueue :DispatchQueue = DispatchQueue(label: "Api queu", attributes: [])
    
    weak var delegate :AnyObject?
    var timeOutIntervar = TimeInterval(10)
    
    override init() {
        super.init()
    }
    
    //URLSession
    
    func endSession() {
        _session.finishTasksAndInvalidate()
    }
    
    //API
    
    final func heartbeat(_ server :Server) {
        _apiDipatchQueue.async(execute: {
                () -> Void in
                
                let request = NSMutableURLRequest(url: URL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/heartbeat"))!)
                request.httpMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.timeoutInterval = self.timeOutIntervar / 2
                
                let task = self._session.dataTask(with: request, completionHandler: {
                    data, response, error -> Void in
                    
                    if(data == nil) {
                        
                        DispatchQueue.main.async
                            {
                                if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.heartbeatResponceFromServer(_:successed:))) {
                                    (self.delegate as! APIManagerDelegate).heartbeatResponceFromServer!(server ,successed :false)
                                }
                        }
                        
                        return
                    }
                    
                    let layers = (try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)) as? NSDictionary
                    
                    if(layers == nil) {
                        
                        DispatchQueue.main.async
                            {
                                if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.heartbeatResponceFromServer(_:successed:))) {
                                    (self.delegate as! APIManagerDelegate).heartbeatResponceFromServer!(server ,successed :false)
                                }
                        }
                        
                        print("NIS is not available!")
                    }
                    else {
                        
                        self.timeSynchronize(server)
                        
                        DispatchQueue.main.async
                            {
                                if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.heartbeatResponceFromServer(_:successed:))) {
                                    (self.delegate as! APIManagerDelegate).heartbeatResponceFromServer!(server ,successed :true)
                                }
                        }
                    }
                })
                
                task.resume()
        })
    }
    
    final func accountGet(_ server :Server, account_address :String)  {
        _apiDipatchQueue.async(execute: {
                () -> Void in
                
                let request = NSMutableURLRequest(url: URL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/account/get?address=" + account_address))!)
            
                request.httpMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.timeoutInterval = self.timeOutIntervar
                
                let task = self._session.dataTask(with: request, completionHandler: {
                    data, response, error -> Void in
                    
                    if(data == nil) {
                        
                        DispatchQueue.main.async
                            {
                                if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.accountGetResponceWithAccount(_:))) {
                                    (self.delegate as! APIManagerDelegate).accountGetResponceWithAccount!(nil)
                                }
                        }
                        
                        return
                    }
                    
                    let layers = (try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)) as? NSDictionary
                    if(layers == nil) {
                        
                        DispatchQueue.main.async
                            {
                                if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.accountGetResponceWithAccount(_:))) {
                                    (self.delegate as! APIManagerDelegate).accountGetResponceWithAccount!(nil)
                                }
                        }
                    }
                    else if (layers! as NSDictionary).object(forKey: "error")  == nil {
                        let requestData :AccountGetMetaData = AccountGetMetaData()
                        
                        requestData.getFrom(layers! as NSDictionary)
                        
                        DispatchQueue.main.async
                            {
                                if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.accountGetResponceWithAccount(_:))) {
                                    (self.delegate as! APIManagerDelegate).accountGetResponceWithAccount!(requestData)
                                }
                        }
                    }
                    else {
                        DispatchQueue.main.async
                            {
                                if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.accountGetResponceWithAccount(_:))) {
                                    (self.delegate as! APIManagerDelegate).accountGetResponceWithAccount!(nil)
                                }
                        }
                    }
                })
                
                task.resume()
        })
    }
    
    final func accountHarvests(_ server :Server, account_address :String)  {
        _apiDipatchQueue.async(execute: {
            () -> Void in
            
            let request = NSMutableURLRequest(url: URL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/account/harvests?address=" + account_address))!)
            
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.timeoutInterval = self.timeOutIntervar
            
            let task = self._session.dataTask(with: request, completionHandler: {
                data, response, error -> Void in
                
                if(data == nil) {
                    
                    DispatchQueue.main.async
                        {
                            if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.accountHarvestResponceWithBlocks(_:))) {
                                (self.delegate as! APIManagerDelegate).accountHarvestResponceWithBlocks!(nil)
                            }
                    }
                    
                    return
                }
                
                let layers = (try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)) as? NSDictionary
                if(layers == nil) {
                    
                    DispatchQueue.main.async
                        {
                            if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.accountHarvestResponceWithBlocks(_:))) {
                                (self.delegate as! APIManagerDelegate).accountHarvestResponceWithBlocks!(nil)
                            }
                    }
                }
                else if (layers! as NSDictionary).object(forKey: "error")  == nil {
                    var blocks :[BlockGetMetaData] = []
                    
                    for blockDic in layers?.object(forKey: "data") as! [NSDictionary] {
                        let block :BlockGetMetaData = BlockGetMetaData()
                        block.getFrom(blockDic)
                        blocks.append(block)
                    }
                    
                    DispatchQueue.main.async
                        {
                            if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.accountHarvestResponceWithBlocks(_:))) {
                                (self.delegate as! APIManagerDelegate).accountHarvestResponceWithBlocks!(blocks)
                            }
                    }
                }
                else {
                    DispatchQueue.main.async
                        {
                            if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.accountHarvestResponceWithBlocks(_:))) {
                                (self.delegate as! APIManagerDelegate).accountHarvestResponceWithBlocks!(nil)
                            }
                    }
                }
            })
            
            task.resume()
        })
    }
    
    final func accountTransfersAll(_ server :Server, account_address :String, aditional :String = "") {
        _apiDipatchQueue.async(execute: {
                () -> Void in

                let request = NSMutableURLRequest(url: URL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/account/transfers/all?address=" + account_address + aditional))!)
            
                request.httpMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.timeoutInterval = self.timeOutIntervar
                
                let task = self._session.dataTask(with: request, completionHandler: {
                    data, response, error -> Void in
                    error?.localizedDescription
                    if(data == nil) {
                        
                        DispatchQueue.main.async {
                            if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.accountTransfersAllResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).accountTransfersAllResponceWithTransactions!(nil)
                            }
                        }
                        
                        return
                    }
                    
                    let layers = (try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)) as? NSDictionary
                    if(layers == nil) {
                        
                        DispatchQueue.main.async {
                            if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.accountTransfersAllResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).accountTransfersAllResponceWithTransactions!(nil)
                            }
                        }
                    }
                    else if (layers! as NSDictionary).object(forKey: "error")  == nil {
                        let data :[NSDictionary] = (layers! as NSDictionary).object(forKey: "data") as! [NSDictionary]
                        
                        var requestDataAll :[TransactionPostMetaData] = [TransactionPostMetaData]()
                        
                        for object in data
                        {
                            let meta :NSDictionary = object.object(forKey: "meta") as! NSDictionary
                            let transaction :NSDictionary = object.object(forKey: "transaction") as! NSDictionary
                            
                            switch(transaction.object(forKey: "type") as! Int) {
                            case transferTransaction :
                                
                                let requestData :_TransferTransaction = _TransferTransaction()
                                
                                requestData.getBeginFrom(meta)
                                requestData.getFrom(transaction)
                                requestDataAll.append(requestData)
                                
                            case multisigAggregateModificationTransaction :
                                
                                let requestData :AggregateModificationTransaction = AggregateModificationTransaction()
                                
                                requestData.getBeginFrom(meta)
                                requestData.getFrom(transaction)
                                requestDataAll.append(requestData)
                                
                            case multisigTransaction :
                                
                                let requestData :_MultisigTransaction = _MultisigTransaction()
                                
                                requestData.getBeginFrom(meta)
                                requestData.getFrom(transaction)
                                requestDataAll.append(requestData)
                                
                            default :
                                break
                            }
                        }
                        
                        DispatchQueue.main.async {
                            if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.accountTransfersAllResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).accountTransfersAllResponceWithTransactions!(requestDataAll)
                            }
                        }
                    }
                    else {
                        
                        DispatchQueue.main.async {
                            if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.accountTransfersAllResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).accountTransfersAllResponceWithTransactions!(nil)
                            }
                        }
                    }
                })
                
                task.resume()
            })
    }
    
    final func unconfirmedTransactions(_ server :Server, account_address :String) {

        _apiDipatchQueue.async(execute: {
                () -> Void in

                let request = NSMutableURLRequest(url: URL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/account/unconfirmedTransactions?address=" + account_address))!)
            
                request.httpMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.timeoutInterval = self.timeOutIntervar
                
                let task = self._session.dataTask(with: request, completionHandler: {
                    data, response, error -> Void in
                    
                    if(data == nil) {
                        
                        DispatchQueue.main.async {
                            if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.unconfirmedTransactionsResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).unconfirmedTransactionsResponceWithTransactions!(nil)
                            }
                        }
                        
                        return
                    }
                    
                    let layers = (try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)) as? NSDictionary
                    if(layers == nil) {
                        
                        DispatchQueue.main.async {
                            if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.unconfirmedTransactionsResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).unconfirmedTransactionsResponceWithTransactions!(nil)
                            }
                        }
                    }
                    else if (layers! as NSDictionary).object(forKey: "error")  == nil {
                        let data :[NSDictionary] = (layers! as NSDictionary).object(forKey: "data") as! [NSDictionary]
                        
                        var requestDataAll :[TransactionPostMetaData] = [TransactionPostMetaData]()
                        
                        print("\nRequest : /account/unconfirmedTransactions")
                        
                        for object in data {
                            let meta :NSDictionary = object.object(forKey: "meta") as! NSDictionary
                            
                            let transaction :NSDictionary = object.object(forKey: "transaction") as! NSDictionary
                            
                            switch(transaction.object(forKey: "type") as! Int) {
                            case transferTransaction :
                                
                                let requestData :_TransferTransaction = _TransferTransaction()
                                
                                if  let metaData = meta.object(forKey: "data") as? String
                                {
                                    requestData.data = metaData
                                }
                                
                                requestData.getFrom(transaction)
                                requestDataAll.append(requestData)
                                
                            case multisigAggregateModificationTransaction :
                                
                                let requestData :AggregateModificationTransaction = AggregateModificationTransaction()
                                
                                if  meta.object(forKey: "data") != nil
                                {
                                    requestData.data = meta.object(forKey: "data") as? String
                                }
                                
                                requestData.getFrom(transaction)
                                requestDataAll.append(requestData)
                                
                            case multisigTransaction :
                                
                                let requestData :_MultisigTransaction = _MultisigTransaction()
                                
                                if  meta.object(forKey: "data") != nil
                                {
                                    requestData.data = meta.object(forKey: "data") as? String
                                }
                                
                                requestData.getFrom(transaction)
                                requestDataAll.append(requestData)
                                
                            default :
                                break
                            }
                        }
                        
                        DispatchQueue.main.async {
                            if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.unconfirmedTransactionsResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).unconfirmedTransactionsResponceWithTransactions!(requestDataAll)
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.unconfirmedTransactionsResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).unconfirmedTransactionsResponceWithTransactions!(nil)
                            }
                        }
                    }
                })
                
                task.resume()
            })
    }
    
    final func prepareAnnounce(_ server :Server, transaction :TransactionPostMetaData) {
        _apiDipatchQueue.async(execute: {
                () -> Void in

                let signedTransaction :SignedTransactionMetaData = SignManager.signTransaction(transaction)
                
                let request = NSMutableURLRequest(url: URL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/transaction/announce"))!)
                
                request.httpMethod = "POST"
                
                let params = ["data" : signedTransaction.dataT ,  "signature" : signedTransaction.signatureT ] as Dictionary<String, String>
                
                var str: Data?
                do {
                    str = try JSONSerialization.data(withJSONObject: params, options: [])
                } catch  {
                    str = nil
                }
                
                request.httpBody = str
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.timeoutInterval = self.timeOutIntervar

            let task = self._session.dataTask(with: request, completionHandler: {
                    data, response, error -> Void in
                    
                    if(data == nil) {
                        
                        DispatchQueue.main.async {
                            if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.prepareAnnounceResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).prepareAnnounceResponceWithTransactions!(nil)
                            }
                        }
                        
                        return
                    }
                    
                    let layers = (try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)) as? NSDictionary
                    if(layers == nil) {
                        
                        DispatchQueue.main.async {
                            if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.prepareAnnounceResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).prepareAnnounceResponceWithTransactions!(nil)
                            }
                        }
                    }
                    else if (layers! as NSDictionary).object(forKey: "error")  == nil {

                        let message :String = (layers! as NSDictionary).object(forKey: "message") as! String
                        
                        if message == "SUCCESS" {
                            DispatchQueue.main.async {
                                if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.prepareAnnounceResponceWithTransactions(_:))) {
                                    (self.delegate as! APIManagerDelegate).prepareAnnounceResponceWithTransactions!([transaction])
                                }
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.prepareAnnounceResponceWithTransactions(_:))) {
                                    (self.delegate as! APIManagerDelegate).prepareAnnounceResponceWithTransactions!([])
                                    (self.delegate as! APIManagerDelegate).failWithError?(message)
                                }
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            if self.delegate != nil && self.delegate!.responds(to: #selector(APIManagerDelegate.prepareAnnounceResponceWithTransactions(_:))) {
                                (self.delegate as! APIManagerDelegate).prepareAnnounceResponceWithTransactions!(nil)
                            }
                        }
                    }
                })
                
                task.resume()
            })
    }
    
    final func timeSynchronize(_ server :Server) {
        _apiDipatchQueue.async(execute: {
                () -> Void in

                let request = NSMutableURLRequest(url: URL(string: (server.protocolType + "://" + server.address + ":" + server.port + "/time-sync/network-time" ))!)
            
                request.httpMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.timeoutInterval = self.timeOutIntervar
                
                let task = self._session.dataTask(with: request, completionHandler: {
                    data, response, error -> Void in
                    
                    guard let data = data else {
                        return
                    }
                    
                    let layers = (try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)) as? NSDictionary
                    if(layers != nil) {
                        let date  = (layers! as NSDictionary).object(forKey: "receiveTimeStamp") as! Double
                        
                        TimeSynchronizator.nemTime = date / 1000
                    }
                })
                
                task.resume()
            })
    }
    
    func downloadImage(_ url: URL, responce: @escaping ((_ image: UIImage) -> Void)){
        print("Started downloading \"\(url.deletingPathExtension().lastPathComponent)\".")
        getDataFromUrl(url) { (data, response, error)  in
            DispatchQueue.main.async { () -> Void in
                guard let data = data , error == nil else { return }
                print("Finished downloading \"\(url.deletingPathExtension().lastPathComponent)\".")
                guard let image = UIImage(data: data) else { return }
                responce(image)
            }
        }
    }
    
    func getDataFromUrl(_ url:URL, completion: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: NSError? ) -> Void)) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            completion(data, response, error)
            }) .resume()
    }
}





