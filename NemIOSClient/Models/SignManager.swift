
import UIKit

class SignManager: NSObject
{
    final class func signTransaction(transaction :TransactionPostMetaData )->SignedTransactionMetaData {
        let signedTransaction :SignedTransactionMetaData = SignedTransactionMetaData()
        
        var array = SignManager.dataGeneration(transaction)
        var toString = ""
        
        for value in array {
            toString = toString + (NSString(format: "%02x", value) as String)
        }
        
        signedTransaction.dataT = toString
        
        toString = ""
        array = SignManager.signatureGeneration(array)
        
        for value in array {
            toString = toString + (NSString(format: "%02x", value) as String)
        }
        
        signedTransaction.signatureT = toString
        
        return signedTransaction
    }
    
    final class func signatureGeneration(data : Array<UInt8> )->Array<UInt8> {
        let myPrivateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        let myPublicKey = KeyGenerator.generatePublicKey(myPrivateKey)

        var processData : Array<UInt8> = Array(data)
        var privateKey :Array<UInt8> = Array(myPrivateKey.utf8)
        var publicKey :Array<UInt8> = Array(myPublicKey.utf8)
        var signature : Array<UInt8> = Array(count: 64, repeatedValue: 0)
        
        Sign(&signature, &processData, Int32(processData.count), &publicKey, &privateKey)
        
        return signature
    }
    
    final class func dataGeneration(transaction :TransactionPostMetaData )->Array<UInt8> {
        var result :Array<UInt8> = Array<UInt8>()
        
        let commonPart :Array<UInt8> = SignManager.commonPart(transaction ,isMultisignPart :false )
        
        var transactionDependentPart :Array<UInt8>!
        
        switch (transaction.type) {
        case transferTransaction :
            
            transactionDependentPart = transferTransactionPart(transaction as! TransferTransaction)
            
        case multisigAggregateModificationTransaction :
            
            transactionDependentPart = aggregateModificationTransactionPart(transaction as! AggregateModificationTransaction)
            
        case multisigSignatureTransaction:
            
            transactionDependentPart = multisigSignatureTransactionPart(transaction as! MultisigSignatureTransaction)
            
        default :
            break
        }
        
        let publicKey = KeyGenerator.generatePublicKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey))
        
        if publicKey != transaction.signer {
            let multisignCommonPart :Array<UInt8> = SignManager.commonPart(transaction  ,isMultisignPart :true )
            result = multisignCommonPart
            
            let transactionLength :Array<UInt8> = String(Int64(commonPart.count + transactionDependentPart.count), radix: 16).asByteArrayEndian(4)
            result = result + transactionLength
        }
        
        result = result + commonPart
        result = result + transactionDependentPart
        
        return result
    }
    
    final class func commonPart(transaction :TransactionPostMetaData ,isMultisignPart :Bool )->Array<UInt8> {
        var result :Array<UInt8> = Array<UInt8>()
        
        var transactionType :Array<UInt8>!
        var fee :Array<UInt8>!
        var publicKey :Array<UInt8>!
        
        if isMultisignPart {
            transactionType = String(Int64(multisigTransaction), radix: 16).asByteArrayEndian(4)
            fee = String(Int64(6 * 1000000), radix: 16).asByteArrayEndian(8)
            let myPublicKey = KeyGenerator.generatePublicKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey))

            publicKey = myPublicKey.asByteArray()

        }
        else {
            transactionType = String(Int64(transaction.type), radix: 16).asByteArrayEndian(4)
            fee = String(Int(transaction.fee) * 1000000, radix: 16).asByteArrayEndian(8)
            publicKey = transaction.signer.asByteArray()

        }

        result = result + transactionType
        
        var version :Array<UInt8>!
        if transaction.type == multisigAggregateModificationTransaction {
            version = [2 , 0 , 0, network ]
        }
        else {
            version = [1 , 0 , 0, network ]
        }
        
        result = result + version
        
        let timeStamp :Array<UInt8> = String(Int64(transaction.timeStamp), radix: 16).asByteArrayEndian(4)
        result = result + timeStamp
        
        let publicKeyLength :Array<UInt8> = [32 , 0 , 0 , 0]
        result = result + publicKeyLength
        
        result = result + publicKey
        
        result = result + fee
        
        let deadline :Array<UInt8> = String(Int64(transaction.deadline), radix: 16).asByteArrayEndian(4)
        result = result + deadline
        
        return result
    }
    
    final class func transferTransactionPart(transaction :TransferTransaction)->Array<UInt8> {
        var result :Array<UInt8> = Array<UInt8>()
        
        let addressLength :Array<UInt8> = [40 , 0 , 0 , 0]
        result = result + addressLength
        
        let address :Array<UInt8> = Array<UInt8>(transaction.recipient.utf8)
        result = result + address
        
        let amount = String(Int64(transaction.amount * 1000000), radix: 16).asByteArrayEndian(8)
        result = result + amount
        
        if transaction.message.payload != nil &&  transaction.message.payload!.count > 0 {
            let payload :Array<UInt8> = transaction.message.payload!
            let length :Int = payload.count + 8
            
            let messageLength :Array<UInt8> = String(length, radix: 16).asByteArrayEndian(4)
            result = result + messageLength
            
            let messageType :Array<UInt8> = [UInt8(transaction.message.type) , 0 , 0, 0 ]
            result = result + messageType
            
            let payloadLength :Array<UInt8> = String(payload.count, radix: 16).asByteArrayEndian(4)
            result = result + payloadLength
            
            result = result + payload
        }
        else {
            let messageLength :Array<UInt8> = [0 , 0 , 0 , 0]
            result = result + messageLength
        }
        
        return result
    }
    
    final class func importanceTransactionPart(transaction :ImportanceTransferTransaction)->Array<UInt8> {
        var result :Array<UInt8> = Array<UInt8>()
        
        let mode :Array<UInt8> =  String(transaction.mode, radix: 16).asByteArrayEndian(4)
        result = result + mode
        
        let lengthOfRemoutPublicKey :Array<UInt8> =  String(transaction.lengthOfRemoutPublicKey, radix: 16).asByteArrayEndian(4)
        result = result + lengthOfRemoutPublicKey
        
        let remoutPublicKey :Array<UInt8> =  transaction.remoutPublicKey.asByteArray()
        result = result + remoutPublicKey
        
        return result
    }
    
    final class func multisigSignatureTransactionPart(transaction :MultisigSignatureTransaction)->Array<UInt8> {
        var result :Array<UInt8> = Array<UInt8>()
        
        let lengthOfHashObject :Array<UInt8> =  String(transaction.lengthOfHashObject, radix: 16).asByteArrayEndian(4)
        result = result + lengthOfHashObject

        let lengthOfHash :Array<UInt8> =  String(transaction.lengthOfHash, radix: 16).asByteArrayEndian(4)
        result = result + lengthOfHash
        
        let transactionHash :Array<UInt8> =  transaction.transactionHash.asByteArray()
        result = result + transactionHash
        
        let lengthOfMultisigAccout :Array<UInt8> =  String(transaction.lengthOfMultisigAccout, radix: 16).asByteArrayEndian(4)
        result = result + lengthOfMultisigAccout
        
        let multisigAccountAddress :Array<UInt8> =  Array<UInt8>(transaction.multisigAccountAddress.utf8)
        result = result + multisigAccountAddress
        
        return result
    }
    
    final class func aggregateModificationTransactionPart(transaction :AggregateModificationTransaction)->Array<UInt8> {
        var result :Array<UInt8> = Array<UInt8>()
        
        let modificationsCount :Array<UInt8> = String(transaction.modifications.count, radix: 16).asByteArrayEndian(4)
        result = result + modificationsCount
        
        for modification in transaction.modifications {
            let lengthOfModification :Array<UInt8> = String(modification.lengthOfModification, radix: 16).asByteArrayEndian(4)
            result = result + lengthOfModification
            
            let modificationType :Array<UInt8> = String(modification.modificationType, radix: 16).asByteArrayEndian(4)
            result = result + modificationType
            
            let lengthOfPublicKey :Array<UInt8> = String(modification.lengthOfPublicKey, radix: 16).asByteArrayEndian(4)
            result = result + lengthOfPublicKey
            
            let publicKey :Array<UInt8> = modification.publicKey.asByteArray()
            result = result + publicKey

        }
        let relativeChange :Array<UInt8> = String(transaction.minCosignatory, radix: 16).asByteArrayEndian(4)
        let lengthOfMinCosignatory :Array<UInt8> = String(relativeChange.count, radix: 16).asByteArrayEndian(4)
        
        result = result + lengthOfMinCosignatory
        result = result + relativeChange
        
        return result
    }
}



