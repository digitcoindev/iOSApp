import Foundation
import CoreData

class Wallet: NSManagedObject
{
    
    @NSManaged var lastTransactionHash: String?
    @NSManaged var login: String
    @NSManaged var privateKey: String
    @NSManaged var correspondents: NSSet
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, login: String, privateKey: String) -> Wallet {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Wallet", inManagedObjectContext: moc) as! Wallet
        newItem.login = login
        newItem.privateKey = privateKey
        
        return newItem
    }
}
