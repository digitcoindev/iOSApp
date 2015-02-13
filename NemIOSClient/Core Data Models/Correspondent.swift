import Foundation
import CoreData

class Correspondent: NSManagedObject
{

    @NSManaged var key: String
    @NSManaged var name: String
    @NSManaged var messages: NSSet

    class func createInManagedObjectContext(moc: NSManagedObjectContext, key: String, name: String) -> Correspondent
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Correspondent", inManagedObjectContext: moc) as Correspondent
        newItem.key = key
        newItem.name = name
        
        return newItem
    }
}
