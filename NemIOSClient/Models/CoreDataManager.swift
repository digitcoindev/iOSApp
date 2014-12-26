//
//  CoreDataManager.swift
//  NemIOSClient
//
//  Created by Bodya Bilas on 23.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject
{
    lazy var managedObjectContext : NSManagedObjectContext? =
    {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        if let managedObjectContext = appDelegate.managedObjectContext
        {
            return managedObjectContext
        }
        else
        {
            return nil
        }
    }()
    
    override init ()
    {
        super.init()
    }
    //Wallet
    
    func getWallets()->[Wallet]
    {
        let fetchRequest = NSFetchRequest(entityName: "Wallet")
        
        if var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Wallet]
        {
            return fetchResults
        }
        else
        {
            var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Wallet]
            
            return fetchResults!
        }
    }
    
    func addWallet(loggin: String, password: String)
    {
        Wallet.createInManagedObjectContext(self.managedObjectContext!,login: loggin, password: password)
        
        commit()
    }
    
    //Server
    
    func getServers()->[Server]
    {
        let fetchRequest = NSFetchRequest(entityName: "Server")
        
        if var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Server]
        {
            if(fetchResults.count == 0)
            {
                Server.createInManagedObjectContext(self.managedObjectContext!, name: "MyFirstServer", address: "10.100.10.1", port: "7890")
                Server.createInManagedObjectContext(self.managedObjectContext!, name: "MySecondServer", address: "10.100.10.2", port: "7890")
                Server.createInManagedObjectContext(self.managedObjectContext!, name: "MyThirdServer", address: "10.100.10.3", port: "7890")
                
                commit()
                
                fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as [Server]
            }
            
            return fetchResults
        }
        else
        {
            Server.createInManagedObjectContext(self.managedObjectContext!, name: "MyFirstServer", address: "10.100.10.1", port: "7890")
            Server.createInManagedObjectContext(self.managedObjectContext!, name: "MySecondServer", address: "10.100.10.2", port: "7890")
            Server.createInManagedObjectContext(self.managedObjectContext!, name: "MyThirdServer", address: "10.100.10.3", port: "7890")
            
            var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Server]
            
            return fetchResults!
        }
    }
    
    func addServer(name: String, address: String, port: String)
    {
        Server.createInManagedObjectContext(self.managedObjectContext!, name: name, address: address, port: port)
        
        commit()
    }
    
    //User
    
    func getUsers()->[User]
    {
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        if var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [User]
        {
            if(fetchResults.count == 0)
            {
                User.createInManagedObjectContext(self.managedObjectContext!, pin1: "", state1: "0")
                
                commit()
                
                fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as [User]
            }
            
            return fetchResults
        }
        else
        {
            User.createInManagedObjectContext(self.managedObjectContext!, pin1: "", state1: "0")
            
            var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [User]
            
            return fetchResults!
        }
    }
    
    func userPin(pin1 : String)
    {
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        if var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [User]
        {
            if(fetchResults.count != 0)
            {
                fetchResults[0].setValue(pin1, forKey: "pin")
                
                commit()
            }
            else
            {
                println("ERROR : Can't set pin for user. No user detected!")
            }
        }
    }
    
    func userPin()-> String
    {
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        var result :String = "ERROR"
        
        if var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [User]
        {
            if(fetchResults.count != 0)
            {
                result =  fetchResults[0].valueForKey("pin") as String
            }
            else
            {
                println("ERROR : Can't get pin for user. No user detected!")
            }
        }
        return result
    }
    
    func userPinState(state :String)
    {
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        if var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [User]
        {
            if(fetchResults.count != 0)
            {
                fetchResults[0].setValue(state, forKey: "state")
                commit()
            }
            else
            {
                println("ERROR : Can't set state for user pin. No user detected!")
            }
            
        }
    }
    
    func userPinState()-> String
    {
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        var result :String = "ERROR"
        
        if var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [User]
        {
            if(fetchResults.count != 0)
            {
                result = fetchResults[0].valueForKey("state") as String
            }
            else
            {
                println("ERROR : Can't get state for user pin . No user detected!")
            }
        }
        return result
    }
    
    //General
    
    func commit()
    {
        self.managedObjectContext?.save(nil)

    }

}
