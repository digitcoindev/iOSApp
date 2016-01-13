import UIKit
import CoreData

class CoreDataManager: NSObject
{
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
    }()
    
    override init () {
        super.init()
    }
    //MARK: - Wallet
    
    final func getWallets()->[Wallet] {
        let fetchRequest = NSFetchRequest(entityName: "Wallet")
        
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Wallet] {
            return fetchResults
        }
        else {
            let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Wallet]
            
            return fetchResults!
        }
    }
    
    final func addWallet(loggin: String, password: String, privateKey: String ,salt :String) {
        Wallet.createInManagedObjectContext(self.managedObjectContext!,login: loggin, password: password ,privateKey : privateKey ,salt :salt)
        
        commit()
    }
    
    final func deleteWallet(wallet wallet :Wallet) {
        self.managedObjectContext!.deleteObject(wallet)
        
        commit()
    }
    
    //MARK: - Invoice
    
    final func getInvoice()->[Invoice] {
        let fetchRequest = NSFetchRequest(entityName: "Invoice")
        
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Invoice] {
            return fetchResults
        }
        
        return [Invoice]()
    }
    
    final func addInvoice(invoice:InvoiceData)->Invoice {
        let number = getInvoice().count
        let result = Invoice.createInManagedObjectContext(self.managedObjectContext!, address: invoice.address, name: invoice.name, message: invoice.message, amount: invoice.amount, number:number )
        commit()
        return result
    }
    
    //MARK: - Server

    final func getServers()->[Server] {
        let fetchRequest = NSFetchRequest(entityName: "Server")
        
        if var fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Server] {
            if(fetchResults.count == 0) {
                _createDefaultServers()
                
                fetchResults = (try! managedObjectContext!.executeFetchRequest(fetchRequest)) as! [Server]
            }
            
            return fetchResults
        }
        else {            
            _createDefaultServers()
            
            let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Server]
            
            return fetchResults!
        }
    }
    private final func _createDefaultServers() {
        Server.createInManagedObjectContext(self.managedObjectContext!, name: "http", address: "artygeek.net", port: "7890")
        Server.createInManagedObjectContext(self.managedObjectContext!, name: "http", address: "211.107.113.251", port: "7890")
        Server.createInManagedObjectContext(self.managedObjectContext!, name: "http", address: "37.187.70.29", port: "7890")
        Server.createInManagedObjectContext(self.managedObjectContext!, name: "http", address: "107.179.25.32", port: "7890")
        
        commit()
    }
    
    final func addServer(name: String, address: String, port: String) -> Server {
        let server = Server.createInManagedObjectContext(self.managedObjectContext!, name: name, address: address, port: port)
        
        commit()
        
        return server
    }
    
    final func deleteServer(server server :Server) {
        self.managedObjectContext!.deleteObject(server)
        
        commit()
    }
    
    //MARK: - LoadData
    
    final func getLoadData()->LoadData {
        let fetchRequest = NSFetchRequest(entityName: "LoadData")
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [LoadData]
        if (fetchResults?.count > 0) {
            return fetchResults?.first! as LoadData!
        }
        else {
            let corespondent :LoadData = LoadData.createInManagedObjectContext(self.managedObjectContext!)
            
            commit()
            
            return corespondent
        }
    }
    
    //MARK: - General
    
    final func commit() {
        do {
            try self.managedObjectContext?.save()
        } catch _ {
        }
    }
}
