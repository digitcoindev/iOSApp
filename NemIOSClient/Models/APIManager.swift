//
//  APIManager.swift
//  NemIOSClient
//
//  Created by Dominik Lyubomyr on 18.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

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
    
    func heartbeat(address :String, port :String) -> Bool
    {
        var heartbeat : Bool = false
        var request = NSMutableURLRequest(URL: NSURL(string: ("http://" + address + ":" + port + "/heartbeat")))
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
                    
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: '\(jsonStr)'")
                }
                else
                {
                    println("Succes")
                    
                    var json1 :NSDictionary = (layers! as NSDictionary).objectForKey("json") as NSDictionary
                    
                    if (json1.objectForKey("message") as String == "ok")
                    {
                        heartbeat = true
                    }
                }
        })
        
        task.resume()
        
        return heartbeat
    }
    
}
