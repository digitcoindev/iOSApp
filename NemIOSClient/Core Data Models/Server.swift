import Foundation
import CoreData

class Server: NSManagedObject
{

    @NSManaged var protocolType: String
    @NSManaged var address: String
    @NSManaged var port: String

    class func createInManagedObjectContext(moc: NSManagedObjectContext, name: String, address: String, port: String) -> Server
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Server", inManagedObjectContext: moc) as Server
        newItem.protocolType = name
        newItem.address = address
        newItem.port = port
        
        return newItem
    }
}
