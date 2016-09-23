import Foundation
import CoreData

class _Invoice: NSManagedObject
{

    @NSManaged var name: String
    @NSManaged var address: String
//    @NSManaged var number: NSNumber
//    @NSManaged var amount: NSNumber
    @NSManaged var message: String

//    class func createInManagedObjectContext(_ moc: NSManagedObjectContext, address: String, name: String , message: String , amount: Double , number: Int ) -> Invoice {
//        let newItem = NSEntityDescription.insertNewObject(forEntityName: "Invoice", into: moc) as! Invoice
//        newItem.address = address
//        newItem.name = name
//        newItem.message = message
////        newItem.amount = amount
////        newItem.number = number
//        
//        return newItem
//    }
}
 
