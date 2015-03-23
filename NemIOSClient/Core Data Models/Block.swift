import Foundation
import CoreData

class Block: NSManagedObject
{

    @NSManaged var height: NSNumber
    @NSManaged var timeStamp: NSNumber
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, height :Double , timeStamp : Double) -> Block
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Block", inManagedObjectContext: moc) as Block
        
        newItem.height =  NSNumber(double: height)
        newItem.timeStamp = NSNumber(double: timeStamp)

        return newItem
    }
}
