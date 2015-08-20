import Foundation
import CoreData

class LoadData: NSManagedObject
{

    @NSManaged var currentServer: NemIOSClient.Server
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext) -> LoadData {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("LoadData", inManagedObjectContext: moc) as! LoadData
        
        
        return newItem
    }
}
