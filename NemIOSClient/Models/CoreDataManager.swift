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
        let sortDescriptor = NSSortDescriptor(key: "position", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Wallet] {
            return fetchResults
        }
        
        return [Wallet]()
    }
    
    final func addWallet(loggin: String, privateKey: String) {
        
        Wallet.createInManagedObjectContext(self.managedObjectContext!, login: loggin, privateKey : privateKey, position: self.getWallets().count)
        
        commit()
    }
    
    final func deleteWallet(wallet wallet :Wallet) {
        
        let position = wallet.position
        
        self.managedObjectContext!.deleteObject(wallet)
        
        for inWallet in self.getWallets() {
            if Int(inWallet.position) > Int(position) {
                inWallet.position = Int(inWallet.position) - Int(position)
            }
        }
        
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
        Server.createInManagedObjectContext(self.managedObjectContext!, name: "http", address: "37.59.43.140", port: "7890")
        Server.createInManagedObjectContext(self.managedObjectContext!, name: "http", address: "52.62.133.0", port: "7890")
        Server.createInManagedObjectContext(self.managedObjectContext!, name: "http", address: "54.207.48.129", port: "7890")
        Server.createInManagedObjectContext(self.managedObjectContext!, name: "http", address: "52.69.252.224", port: "7890")
        Server.createInManagedObjectContext(self.managedObjectContext!, name: "http", address: "104.128.226.60", port: "7890")
        Server.createInManagedObjectContext(self.managedObjectContext!, name: "http", address: "54.254.215.55", port: "7890")
        Server.createInManagedObjectContext(self.managedObjectContext!, name: "http", address: "193.84.22.102", port: "7890")
        Server.createInManagedObjectContext(self.managedObjectContext!, name: "http", address: "52.79.74.84", port: "7890")
        
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
