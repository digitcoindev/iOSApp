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
    //Wallet
    
    final func getWallets()->[Wallet] {
        let fetchRequest = NSFetchRequest(entityName: "Wallet")
        
        if var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Wallet] {
            return fetchResults
        }
        else {
            var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Wallet]
            
            return fetchResults!
        }
    }
    
    final func addWallet(loggin: String, password: String, privateKey: String ,salt :String) {
        Wallet.createInManagedObjectContext(self.managedObjectContext!,login: loggin, password: password ,privateKey : privateKey ,salt :salt)
        
        commit()
    }
    
    final func deleteWallet(#wallet :Wallet) {
        self.managedObjectContext!.deleteObject(wallet)
        
        commit()
    }
    
     //Invoice
    
    final func getInvoice()->[Invoice] {
        let fetchRequest = NSFetchRequest(entityName: "Invoice")
        
        if var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Invoice] {
            return fetchResults
        }
        
        return [Invoice]()
    }
    
    final func addInvoice(invoice:InvoiceData)->Invoice {
        var number = getInvoice().count
        var result = Invoice.createInManagedObjectContext(self.managedObjectContext!, address: invoice.address, name: invoice.name, message: invoice.message, amount: invoice.amount, number:number )
        commit()
        return result
    }
    
     //Server

    final func getServers()->[Server] {
        let fetchRequest = NSFetchRequest(entityName: "Server")
        
        if var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Server] {
            if(fetchResults.count == 0) {
                _createDefaultServers()
                
                fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as! [Server]
            }
            
            return fetchResults
        }
        else {            
            _createDefaultServers()
            
            var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Server]
            
            return fetchResults!
        }
    }
    private final func _createDefaultServers() {
        Server.createInManagedObjectContext(self.managedObjectContext!, name: "http", address: "192.168.88.27", port: "7890")
        Server.createInManagedObjectContext(self.managedObjectContext!, name: "http", address: "127.0.0.1", port: "7890")
        
        commit()
    }
    
    final func addServer(name: String, address: String, port: String) -> Server {
        var server = Server.createInManagedObjectContext(self.managedObjectContext!, name: name, address: address, port: port)
        
        commit()
        
        return server
    }
    
    final func deleteServer(#server :Server) {
        self.managedObjectContext!.deleteObject(server)
        
        commit()
    }
    
    //LoadData
    
    final func getLoadData()->LoadData {
        let fetchRequest = NSFetchRequest(entityName: "LoadData")
        var fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [LoadData]
        if (fetchResults?.count > 0) {
            return fetchResults?.first! as LoadData!
        }
        else {
            var corespondent :LoadData = LoadData.createInManagedObjectContext(self.managedObjectContext!)
            
            commit()
            
            return corespondent
        }
    }
    
    //General
    
    final func commit() {
        self.managedObjectContext?.save(nil)
    }

}
