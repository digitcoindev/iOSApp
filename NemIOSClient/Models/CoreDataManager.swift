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
    
    final func getWallets()->[Wallet]
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
    
    final func addWallet(loggin: String, password: String, privateKey: String)
    {
        Wallet.createInManagedObjectContext(self.managedObjectContext!,login: loggin, password: password ,privateKey : privateKey)
        
        commit()
    }
    
    //Message
    
    final func getMessages()->[Message]
    {
        let fetchRequest = NSFetchRequest(entityName: "Message")
        
        if var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Message]
        {
            return fetchResults
        }
        else
        {
            var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Message]
            
            return fetchResults!
        }
    }
    
    final func addMessage(from: String, to: String, message: String , date: NSDate , nems: String)
    {
        Message.createInManagedObjectContext(self.managedObjectContext!, from: from, to: to, message: message, date: date , nems: nems)
        
        commit()
    }
    //Transaction
    
    final func getTransaction()->[Transaction]
    {
        let fetchRequest = NSFetchRequest(entityName: "Transaction")
        
        if var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Transaction]
        {
            return fetchResults
        }
        else
        {
            var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Transaction]
            
            return fetchResults!
        }
    }
    
    final func addTransaction(transaction :TransactionGetMetaData)
    {
        Transaction.createInManagedObjectContext(self.managedObjectContext!,transaction :transaction)
        
        commit()
    }
    
    //Correspondent

    final func getCorrespondents()->[Correspondent]
    {
        return State.currentWallet!.correspondents.allObjects as [Correspondent]
    }

    final func getCorrespondent(key :String , address :String) -> Correspondent
    {
        let fetchRequest = NSFetchRequest(entityName: "Correspondent")
        
        var fetchResults :[Correspondent] = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as [Correspondent]
        
        for correspondent in fetchResults
        {
            if correspondent.public_key == key
            {
                return correspondent
            }
        }
        
        var corespondent :Correspondent = Correspondent.createInManagedObjectContext(self.managedObjectContext!,  key: key, name: address , address : address)
        
        commit()
        
        return corespondent
    }
    
    final func addCorrespondent( key: String, name: String , address :String) -> Correspondent
    {
        var corespondent :Correspondent = Correspondent.createInManagedObjectContext(self.managedObjectContext!,  key: key, name: name , address : address)
        
        commit()
        
        return corespondent
    }

    //Server

    final func getServers()->[Server]
    {
        let fetchRequest = NSFetchRequest(entityName: "Server")
        
        if var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Server]
        {
            if(fetchResults.count == 0)
            {
                Server.createInManagedObjectContext(self.managedObjectContext!, name: "http", address: "127.0.0.1", port: "7890")
                
                commit()
                
                fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as [Server]
            }
            
            return fetchResults
        }
        else
        {            
            Server.createInManagedObjectContext(self.managedObjectContext!, name: "http", address: "127.0.0.1", port: "7890")
            
            var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Server]
            
            return fetchResults!
        }
    }
    
    final func addServer(name: String, address: String, port: String) -> Server
    {
        var server = Server.createInManagedObjectContext(self.managedObjectContext!, name: name, address: address, port: port)
        
        commit()
        
        return server
    }
    
    //LoadData
    
    final func getLoadData()->LoadData
    {
        let fetchRequest = NSFetchRequest(entityName: "LoadData")
        var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [LoadData]
        if (fetchResults?.count > 0)
        {
            return fetchResults?.first! as LoadData!
        }
        else
        {
            var corespondent :LoadData = LoadData.createInManagedObjectContext(self.managedObjectContext!)
            
            commit()
            
            return corespondent
        }
    }
    
    //General
    
    final func commit()
    {
        self.managedObjectContext?.save(nil)

    }

}
