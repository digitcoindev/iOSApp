import UIKit
import CoreData

class CoreDataManager: NSObject
{
    var blocks :[Block] = [Block]()
    
    lazy var managedObjectContext : NSManagedObjectContext? =
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
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
    
    final func addWallet(loggin: String, password: String, privateKey: String ,salt :String)
    {
        Wallet.createInManagedObjectContext(self.managedObjectContext!,login: loggin, password: password ,privateKey : privateKey ,salt :salt)
        
        commit()
    }
    
    final func deleteWallet(#wallet :Wallet)
    {
        self.managedObjectContext!.deleteObject(wallet)
        
        commit()
    }
    
    //Block
    
    final func getBlocks()->[Block]
    {
        let fetchRequest = NSFetchRequest(entityName: "Block")
        
        if var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Block]
        {
            return fetchResults
        }
        return [Block]()
    }
    
    final func getBlock(height : Double)->Block?
    {
        blocks = getBlocks()
        for block in blocks as [Block]
        {
            if block.height == height
            {
                return block
            }
        }
        if State.currentServer != nil
        {
            APIManager().getBlockWithHeight(State.currentServer!, height: Int(height))
        }
        
        return nil
    }
    
    final func addBlock(height: Int, timeStamp: Double)->Block
    {
        var block = Block.createInManagedObjectContext(self.managedObjectContext!,height: Double(height), timeStamp:timeStamp)
        
        commit()
        
        return block
    }
    
    //Transaction
    
    final func getTransaction()->[Transaction]
    {
        let fetchRequest = NSFetchRequest(entityName: "Transaction")
        
        if var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Transaction]
        {
            return fetchResults
        }
        
        return [Transaction]()
    }
    
    final func addTransaction(transaction :TransactionPostMetaData)
    {
        Transaction.createInManagedObjectContext(self.managedObjectContext!,transaction :transaction)
        
        commit()
    }
    
    //Invoice
    
    final func getInvoice()->[Invoice]
    {
        let fetchRequest = NSFetchRequest(entityName: "Invoice")
        
        if var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Invoice]
        {
            return fetchResults
        }
        
        return [Invoice]()
    }
    
    final func addInvoice(invoice:InvoiceData)->Invoice
    {
        var number = getInvoice().count
        var result = Invoice.createInManagedObjectContext(self.managedObjectContext!, address: invoice.address, name: invoice.name, message: invoice.message, amount: invoice.amount, number:number )
        commit()
        return result
    }
    
    //Correspondent
    
    final func getCorrespondents()->[Correspondent]
    {
        return State.currentWallet!.correspondents.allObjects as! [Correspondent]
    }
    
    final func getCorrespondent(key :String? , address :String? , name :String?) -> Correspondent
    {
        let fetchRequest = NSFetchRequest(entityName: "Correspondent")
        
        var fetchResults :[Correspondent] = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as! [Correspondent]
        
        for correspondent in fetchResults
        {
            if key != nil
            {
                if correspondent.public_key == key
                {
                    return correspondent
                }
            }
            if address != nil
            {
                if correspondent.address == address
                {
                    return correspondent
                }
            }
        }
        
        var correspondentKey = key
        var correspondentAddress = address
        var correspondentName = name
        
        if key == nil
        {
            correspondentKey = ""
        }
        if address == nil
        {
            correspondentAddress = ""
        }
        else if key != nil
        {
            correspondentAddress = AddressGenerator().generateAddress(correspondentKey!)
        }
        if correspondentName == nil
        {
            correspondentName = correspondentAddress
        }
        
        var corespondent :Correspondent = Correspondent.createInManagedObjectContext(self.managedObjectContext!,  key: correspondentKey!, name: correspondentName! , address : correspondentAddress! ,owner: State.currentWallet!)
        
        commit()
        
        return corespondent
    }
    
    final func addCorrespondent( key: String, name: String , address :String , owner: Wallet) -> Correspondent
    {
        var corespondent :Correspondent = Correspondent.createInManagedObjectContext(self.managedObjectContext!,  key: key, name: name , address : address,owner: owner)
        
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
                
                fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as! [Server]
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
