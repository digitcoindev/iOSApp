import Foundation
import CoreData

class _Server: NSManagedObject
{

    @NSManaged var protocolType: String
    @NSManaged var address: String
    @NSManaged var port: String

    class func createInManagedObjectContext(_ moc: NSManagedObjectContext, name: String, address: String, port: String) -> Server {
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "Server", into: moc) as! Server
        newItem.protocolType = name
        newItem.address = address
        newItem.port = port
        
        return newItem
    }
}
