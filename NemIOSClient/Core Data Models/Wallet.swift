import Foundation
import CoreData

class Wallet: NSManagedObject
{

    @NSManaged var login: String
    @NSManaged var password: String
    @NSManaged var privateKey: String
    @NSManaged var correspondents: NSSet
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, login: String, password: String , privateKey: String) -> Wallet
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Wallet", inManagedObjectContext: moc) as! Wallet
        newItem.login = login
        newItem.password = password
        newItem.privateKey = privateKey
        
        return newItem
    }
}
