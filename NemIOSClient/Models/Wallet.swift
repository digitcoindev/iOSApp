import Foundation
import CoreData

class Wallet: NSManagedObject
{
    
    @NSManaged var lastTransactionHash: String?
    @NSManaged var login: String
    @NSManaged var privateKey: String
    @NSManaged var correspondents: NSSet
    @NSManaged var position: NSNumber
    
    class func createInManagedObjectContext(_ moc: NSManagedObjectContext, login: String, privateKey: String, position: NSNumber) -> Wallet {
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "Wallet", into: moc) as! Wallet
        
        newItem.login = login
        newItem.privateKey = privateKey
        newItem.position = position
        
        return newItem
    }
}
