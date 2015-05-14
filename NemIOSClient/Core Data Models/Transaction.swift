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
    
    struct Store
    {
        static var stackVC : [String] = [String]()
    }
    class func createInManagedObjectContext(moc: NSManagedObjectContext , transaction : TransactionPostMetaData) -> Transaction
    {
        let coreData :CoreDataManager = CoreDataManager()
        var corespondents :[Correspondent] = coreData.getCorrespondents()
        var current_correspondent :Correspondent!
        var find :Bool = false

        switch(transaction.type)
        {
        case transferTransaction :
            find = false
            var myPublicKey = KeyGenerator().generatePublicKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey))
            var myAddress = AddressGenerator().generateAddress(myPublicKey)
            
            if transaction.signer == myPublicKey && (transaction as! TransferTransaction).recipient == myAddress
            {
                for correspondent in corespondents
                {
                    if correspondent.public_key == myPublicKey &&  correspondent.address == myAddress
                    {
                        current_correspondent = correspondent
                        find = true
                    }
                }
            }
            else
            {
                for correspondent in corespondents
                {
                    if correspondent.public_key == transaction.signer || correspondent.address == (transaction as! TransferTransaction).recipient || AddressGenerator().generateAddress(transaction.signer) == correspondent.address
                    {
                        if correspondent.public_key != myPublicKey || correspondent.address != myAddress
                        {
                            current_correspondent = correspondent
                            find = true
                            break
                        }
                    }
                }
            }
            
            if !find
            {
                var address = AddressGenerator().generateAddress( transaction.signer)
                
                if transaction.signer != myPublicKey
                {
                    current_correspondent = coreData.addCorrespondent(transaction.signer, name: address , address :address ,owner: State.currentWallet!)
                }
                else if (transaction as! TransferTransaction).recipient != myAddress
                {
                    current_correspondent = coreData.addCorrespondent("", name: (transaction as! TransferTransaction).recipient , address :(transaction as! TransferTransaction).recipient ,owner: State.currentWallet!)
                }
                else
                {
                    current_correspondent = coreData.addCorrespondent(myPublicKey, name: myAddress , address : myAddress ,owner: State.currentWallet!)
                }
            }
            
            var transactions = current_correspondent.transactions.allObjects as! [Transaction]
            
            for cur_transaction in transactions
            {
                if cur_transaction.id == transaction.id && cur_transaction.height == transaction.height
                {
                    return cur_transaction
                }
            }
                        
            let newItem = NSEntityDescription.insertNewObjectForEntityForName("Transaction", inManagedObjectContext: moc) as! Transaction
            
            newItem.id = transaction.id
            newItem.height = transaction.height
            newItem.signature = transaction.signature
            
            newItem.amount = (transaction as! TransferTransaction).amount
            newItem.fee = transaction.fee
            newItem.recipient = (transaction as! TransferTransaction).recipient
            newItem.type = transaction.type
            newItem.deadline = transaction.deadline
            newItem.signer = transaction.signer
            newItem.message_payload = (transaction as! TransferTransaction).message.payload
            newItem.message_type = (transaction as! TransferTransaction).message.type
            newItem.version = transaction.version
            newItem.owner = current_correspondent
            newItem.timeStamp = transaction.timeStamp
            
            var blocks :[Block] = CoreDataManager().getBlocks()
            
            for block in blocks
            {
                if block.height == transaction.height
                {
                    return newItem
                }
            }
            
            APIManager().getBlockWithHeight(State.currentServer!, height: Int( transaction.height))
            
            return newItem
            
        default:
            break
        }
        
        println("ERROR. function shouldn't get to this point.")
        
        return Transaction()
    }

}
