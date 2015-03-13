import Foundation
import CoreData

class Message: NSManagedObject
{

    @NSManaged var from: String
    @NSManaged var to: String
    @NSManaged var message: String
    @NSManaged var nems: String
    @NSManaged var date: NSDate
    @NSManaged var owner: Correspondent
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, from: String, to: String, message: String , date: NSDate , nems :String) -> Message
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: moc) as Message
        newItem.from = from
        newItem.to = to
        newItem.message = message
        newItem.date = date
        newItem.nems = nems
        
        let coreData :CoreDataManager = CoreDataManager()
        var corespondents :[Correspondent] = coreData.getCorrespondents()
        var find :Bool = false
        
        for correspondent in corespondents
        {
            if correspondent.public_key == from || correspondent.public_key == to
            {
                newItem.owner = correspondent
                find = true
            }
        }
        
        if !find
        {
            if from != "me"
            {
                //newItem.owner = coreData.addCorrespondent(from, name: from ,address: nil)
            }
            else
            {
                //newItem.owner = coreData.addCorrespondent(to, name: to)
            }
        }
        
        return newItem
    }
}
