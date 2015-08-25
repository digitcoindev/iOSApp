import UIKit

class SignManager: NSObject
{
    final class func signTransaction(transaction :TransactionPostMetaData )->SignedTransactionMetaData {
        var signedTransaction :SignedTransactionMetaData = SignedTransactionMetaData()
        
        var array = SignManager.dataGeneration(transaction)
        var toString = ""
        
        for value in array {
            toString = toString + (NSString(format: "%02x", value) as! String)
        }
        
        signedTransaction.dataT = toString
        
        toString = ""
        array = SignManager.signatureGeneration(array)
        
        for value in array {
            toString = toString + (NSString(format: "%02x", value) as! String)
        }
        
        signedTransaction.signatureT = toString
        
        return signedTransaction
    }
    
    final class func signatureGeneration(data : Array<UInt8> )->Array<UInt8> {
        var myPrivateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        var myPublicKey = KeyGenerator.generatePublicKey(myPrivateKey)

        var processData : Array<UInt8> = Array(data)
        var privateKey :Array<UInt8> = Array(myPrivateKey.utf8)
        var publicKey :Array<UInt8> = Array(myPublicKey.utf8)
        var signature : Array<UInt8> = Array(count: 64, repeatedValue: 0)
        
        Sign(&signature, &processData, Int32(processData.count), &publicKey, &privateKey)
        
        return signature
    }
    
    final class func dataGeneration(transaction :TransactionPostMetaData )->Array<UInt8> {
        var result :Array<UInt8> = Array<UInt8>()
        
        var commonPart :Array<UInt8> = SignManager.commonPart(transaction ,isMultisignPart :false )
        
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
        
        var publicKey = KeyGenerator.generatePublicKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey))
        
        if publicKey != transaction.signer {
            var multisignCommonPart :Array<UInt8> = SignManager.commonPart(transaction  ,isMultisignPart :true )
            result = multisignCommonPart
            
            var transactionLength :Array<UInt8> = String(Int64(commonPart.count + transactionDependentPart.count), radix: 16).asByteArrayEndian(4)
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
            var myPublicKey = KeyGenerator.generatePublicKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey))

            publicKey = myPublicKey.asByteArray()

        }
        else {
            transactionType = String(Int64(transaction.type), radix: 16).asByteArrayEndian(4)
            fee = String(Int64(transaction.fee * 1000000), radix: 16).asByteArrayEndian(8)
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
        
        var timeStamp :Array<UInt8> = String(Int64(transaction.timeStamp), radix: 16).asByteArrayEndian(4)
        result = result + timeStamp
        
        var publicKeyLength :Array<UInt8> = [32 , 0 , 0 , 0]
        result = result + publicKeyLength
        
        result = result + publicKey
        
        result = result + fee
        
        var deadline :Array<UInt8> = String(Int64(transaction.deadline), radix: 16).asByteArrayEndian(4)
        result = result + deadline
        
        return result
    }
    
    final class func transferTransactionPart(transaction :TransferTransaction)->Array<UInt8> {
        var result :Array<UInt8> = Array<UInt8>()
        
        var addressLength :Array<UInt8> = [40 , 0 , 0 , 0]
        result = result + addressLength
        
        var address :Array<UInt8> = Array<UInt8>(transaction.recipient.utf8)
        result = result + address
        
        var amount = String(Int64(transaction.amount * 1000000), radix: 16).asByteArrayEndian(8)
        result = result + amount
        
        if transaction.message.payload != "" {
            var payload :Array<UInt8> = transaction.message.payload.asByteArray()
            var length :Int = payload.count + 8
            
            var messageLength :Array<UInt8> = String(length, radix: 16).asByteArrayEndian(4)
            result = result + messageLength
            
            var messageType :Array<UInt8> = [UInt8(transaction.message.type) , 0 , 0, 0 ]
            result = result + messageType
            
            var payloadLength :Array<UInt8> = String(payload.count, radix: 16).asByteArrayEndian(4)
            result = result + payloadLength
            
            result = result + payload

        }
        else {
            var messageLength :Array<UInt8> = [0 , 0 , 0 , 0]
            result = result + messageLength
        }
        
        return result
    }
    
    final class func importanceTransactionPart(transaction :ImportanceTransferTransaction)->Array<UInt8> {
        var result :Array<UInt8> = Array<UInt8>()
        
        var mode :Array<UInt8> =  String(transaction.mode, radix: 16).asByteArrayEndian(4)
        result = result + mode
        
        var lengthOfRemoutPublicKey :Array<UInt8> =  String(transaction.lengthOfRemoutPublicKey, radix: 16).asByteArrayEndian(4)
        result = result + lengthOfRemoutPublicKey
        
        var remoutPublicKey :Array<UInt8> =  transaction.remoutPublicKey.asByteArray()
        result = result + remoutPublicKey
        
        return result
    }
    
    final class func multisigSignatureTransactionPart(transaction :MultisigSignatureTransaction)->Array<UInt8> {
        var result :Array<UInt8> = Array<UInt8>()
        
        var lengthOfHashObject :Array<UInt8> =  String(transaction.lengthOfHashObject, radix: 16).asByteArrayEndian(4)
        result = result + lengthOfHashObject

        var lengthOfHash :Array<UInt8> =  String(transaction.lengthOfHash, radix: 16).asByteArrayEndian(4)
        result = result + lengthOfHash
        
        var transactionHash :Array<UInt8> =  transaction.transactionHash.asByteArray()
        result = result + transactionHash
        
        var lengthOfMultisigAccout :Array<UInt8> =  String(transaction.lengthOfMultisigAccout, radix: 16).asByteArrayEndian(4)
        result = result + lengthOfMultisigAccout
        
        var multisigAccountAddress :Array<UInt8> =  Array<UInt8>(transaction.multisigAccountAddress.utf8)
        result = result + multisigAccountAddress
        
        return result
    }
    
    final class func aggregateModificationTransactionPart(transaction :AggregateModificationTransaction)->Array<UInt8> {
        var result :Array<UInt8> = Array<UInt8>()
        
        var modificationsCount :Array<UInt8> = String(transaction.modifications.count, radix: 16).asByteArrayEndian(4)
        result = result + modificationsCount
        
        for modification in transaction.modifications {
            var lengthOfModification :Array<UInt8> = String(modification.lengthOfModification, radix: 16).asByteArrayEndian(4)
            result = result + lengthOfModification
            
            var modificationType :Array<UInt8> = String(modification.modificationType, radix: 16).asByteArrayEndian(4)
            result = result + modificationType
            
            var lengthOfPublicKey :Array<UInt8> = String(modification.lengthOfPublicKey, radix: 16).asByteArrayEndian(4)
            result = result + lengthOfPublicKey
            
            var publicKey :Array<UInt8> = modification.publicKey.asByteArray()
            result = result + publicKey

        }
        var relativeChange :Array<UInt8> = String(transaction.minCosignatory, radix: 16).asByteArrayEndian(4)
        var lengthOfMinCosignatory :Array<UInt8> = String(relativeChange.count, radix: 16).asByteArrayEndian(4)
        
        result = result + lengthOfMinCosignatory
        result = result + relativeChange
        
        return result
    }
}



