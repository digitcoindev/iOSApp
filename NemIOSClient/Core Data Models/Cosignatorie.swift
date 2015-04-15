import Foundation
import CoreData

class Cosignatorie: NSManagedObject
{

    @NSManaged var publicKey: String
    @NSManaged var wallet: NemIOSClient.Wallet

    class func createInManagedObjectContext(moc: NSManagedObjectContext, publicKey :String) -> Cosignatorie
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Cosignatorie", inManagedObjectContext: moc) as Cosignatorie
        
        newItem.publicKey = publicKey
        newItem.wallet = State.currentWallet!
        
        return newItem
    }
}
