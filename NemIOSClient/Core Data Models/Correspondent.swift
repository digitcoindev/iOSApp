import Foundation
import CoreData

class Correspondent: NSManagedObject
{

    @NSManaged var public_key: String
    @NSManaged var address: String
    @NSManaged var name: String
    @NSManaged var messages: NSSet
    @NSManaged var transactions: NSSet
    @NSManaged var owner: Wallet


    class func createInManagedObjectContext(moc: NSManagedObjectContext, key: String, name: String , address: String) -> Correspondent
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Correspondent", inManagedObjectContext: moc) as! Correspondent
        newItem.public_key = key
        newItem.address = address
        newItem.name = name
        newItem.owner = State.currentWallet!
        
        return newItem
    }
}
