import Foundation
import CoreData

class Invoice: NSManagedObject
{

    @NSManaged var name: String
    @NSManaged var address: String
    @NSManaged var number: NSNumber
    @NSManaged var amount: NSNumber
    @NSManaged var message: String

    class func createInManagedObjectContext(moc: NSManagedObjectContext, address: String, name: String , message: String , amount: Int , number: Int ) -> Invoice
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Invoice", inManagedObjectContext: moc) as! Invoice
        newItem.address = address
        newItem.name = name
        newItem.message = message
        newItem.amount = amount
        newItem.number = number
        
        return newItem
    }
}
 