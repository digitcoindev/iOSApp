import Foundation
import CoreData

class Transaction: NSManagedObject
{

    @NSManaged var id: NSNumber
    @NSManaged var height: NSNumber
    @NSManaged var timeStamp: NSNumber
    @NSManaged var amount: NSNumber
    @NSManaged var signature: String
    @NSManaged var fee: NSNumber
    @NSManaged var recipient: String
    @NSManaged var type: NSNumber
    @NSManaged var deadline: NSNumber
    @NSManaged var message_payload: String
    @NSManaged var signer: String
    @NSManaged var message_type: NSNumber
    @NSManaged var version: NSNumber
    @NSManaged var owner: Correspondent
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext , transaction : TransactionGetMetaData) -> Transaction
    {
        let coreData :CoreDataManager = CoreDataManager()
        var corespondents :[Correspondent] = coreData.getCorrespondents()
        var current_correspondent :Correspondent!
        var find :Bool = false

        for correspondent in corespondents
        {
            if correspondent.public_key == transaction.signer || correspondent.address == transaction.recipient
            {
                current_correspondent = correspondent
                find = true
            }
        }
        
        if !find
        {
            if transaction.signer != KeyGenerator().generatePublicKey(State.currentWallet!.privateKey)
            {
                var address = AddressGenerator().generateAddress( transaction.signer)
                
                current_correspondent = coreData.addCorrespondent(transaction.signer, name: address , address :address)
            }
            else
            {
                current_correspondent = coreData.addCorrespondent("", name: transaction.recipient , address :transaction.recipient )
            }
        }
        
        var transactions = current_correspondent.transactions.allObjects as [Transaction]
        
        for cur_transaction in transactions
        {
            if cur_transaction.id == transaction.id && cur_transaction.height == transaction.height
            {
                return cur_transaction
            }
        }
        
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Transaction", inManagedObjectContext: moc) as Transaction
        
        newItem.id = transaction.id
        newItem.height = transaction.height
        newItem.timeStamp = transaction.timeStamp
        newItem.amount = transaction.amount
        newItem.signature = transaction.signature
        newItem.fee = transaction.fee
        newItem.recipient = transaction.recipient
        newItem.type = transaction.type
        newItem.deadline = transaction.deadline
        newItem.signer = transaction.signer
        newItem.message_payload = transaction.message.payload
        newItem.message_type = transaction.message.type
        newItem.version = transaction.version
        newItem.owner = current_correspondent

        return newItem
    }

}
