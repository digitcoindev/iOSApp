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
    
    func heartbeat(protocolType :String, address :String, port :String) -> Bool
    {
        var heartbeat : Bool = false
        var request = NSMutableURLRequest(URL: NSURL(string: (protocolType + "://" + address + ":" + port + "/heartbeat"))!)
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
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("heartbeatSuccessed", object:layers )

//                    NSNotificationCenter.defaultCenter().postNotificationName("heartbeatDenied", object:nil)

                    
                    println("NIS is not available!")
                }
                else
                {
                    var message :String = (layers! as NSDictionary).objectForKey("message") as String
                    var code :Int = (layers! as NSDictionary).objectForKey("code") as Int
                    var type :Int = (layers! as NSDictionary).objectForKey("type") as Int
                    
                    println("Succes : \n\tCode : \(code)\n\tType : \(type)\n\tMessage : \(message)")
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("heartbeatSuccessed", object:layers )

                    heartbeat = true
                }
        })
        
        task.resume()
        
        heartbeat = true
        
        return heartbeat
    }
    
}
