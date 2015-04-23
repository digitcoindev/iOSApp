import UIKit

class SignManager: NSObject
{
    final class func signTransaction(transaction :TransactionPostMetaData )->SignedTransactionMetaData
    {
        var signedTransaction :SignedTransactionMetaData = SignedTransactionMetaData()
        
        var array = SignManager.dataGeneration(transaction)
        var toString = ""
        
        for value in array
        {
            toString = toString + (NSString(format: "%02x", value) as! String)
        }
        
        signedTransaction.dataT = toString
        
        toString = ""
        array = SignManager.signatureGeneration(array, transaction: transaction)
        
        for value in array
        {
            toString = toString + (NSString(format: "%02x", value) as! String)
        }
        
        signedTransaction.signatureT = toString
        
        return signedTransaction
    }
    
    final class func signatureGeneration(data : Array<UInt8> , transaction : TransactionPostMetaData)->Array<UInt8>
    {
        var processData : Array<UInt8> = Array(data)
        var privateKey :Array<UInt8> = Array(transaction.privateKey.utf8)
        var publicKey :Array<UInt8> = Array(transaction.signer.utf8)
        var signature : Array<UInt8> = Array(count: 64, repeatedValue: 0)
        
        Sign(&signature, &processData, Int32(processData.count), &publicKey, &privateKey)
        
        return signature
    }
    
    final class func dataGeneration(transaction :TransactionPostMetaData )->Array<UInt8>
    {
        var result :Array<UInt8> = Array<UInt8>()
        
        var commonPart :Array<UInt8> = SignManager.commonPart(transaction ,isMultisignPart :false )
        
        var transactionDependentPart :Array<UInt8>!
        
        switch (transaction.type)
        {
        case transferTransaction :
            
            transactionDependentPart = transferTransactionPart(transaction as! TransferTransaction)
            
        case multisigAggregateModificationTransaction :
            
            transactionDependentPart = aggregateModificationTransactionPart(transaction as! AggregateModificationTransaction)
            
        default :
            break
        }
        
        if State.isMultisignAccount 
        {
            var multisignCommonPart :Array<UInt8> = SignManager.commonPart(transaction  ,isMultisignPart :true )
            result = multisignCommonPart
            
            var transactionLength :Array<UInt8> = String(Int64(commonPart.count + transactionDependentPart.count), radix: 16).asByteArrayEndian(4)
            result = result + transactionLength
        }
        
        result = result + commonPart
        result = result + transactionDependentPart
        
        return result
    }
    
    final class func commonPart(transaction :TransactionPostMetaData ,isMultisignPart :Bool )->Array<UInt8>
    {
        var result :Array<UInt8> = Array<UInt8>()
        
        var transactionType :Array<UInt8>!
        var fee :Array<UInt8>!
        
        if isMultisignPart
        {
            transactionType = String(Int64(multisigTransaction), radix: 16).asByteArrayEndian(4)
            fee = String(Int64(6 * 1000000), radix: 16).asByteArrayEndian(8)
        }
        else
        {
            transactionType = String(Int64(transaction.type), radix: 16).asByteArrayEndian(4)
            fee = String(Int64(transaction.fee * 1000000), radix: 16).asByteArrayEndian(8)
        }

        result = result + transactionType
        
        var version :Array<UInt8> = [1 , 0 , 0, network ]
        result = result + version
        
        var timeStamp :Array<UInt8> = String(Int64(transaction.timeStamp), radix: 16).asByteArrayEndian(4)
        result = result + timeStamp
        
        var publicKeyLength :Array<UInt8> = [32 , 0 , 0 , 0]
        result = result + publicKeyLength
        
        var publicKey :Array<UInt8> = transaction.signer.asByteArray()
        result = result + publicKey
        
        result = result + fee
        
        var deadline :Array<UInt8> = String(Int64(transaction.deadline), radix: 16).asByteArrayEndian(4)
        result = result + deadline
        
        return result
    }
    
    final class func transferTransactionPart(transaction :TransferTransaction)->Array<UInt8>
    {
        var result :Array<UInt8> = Array<UInt8>()
        
        var addressLength :Array<UInt8> = [40 , 0 , 0 , 0]
        result = result + addressLength
        
        var address :Array<UInt8> = Array<UInt8>(transaction.recipient.utf8)
        result = result + address
        
        var amount = String(Int64(transaction.amount * 1000000), radix: 16).asByteArrayEndian(8)
        result = result + amount
        
        if transaction.message.payload != ""
        {
            var length :Int = count(transaction.message.payload.utf16) + 8
            var messageLength :Array<UInt8> = String(length, radix: 16).asByteArrayEndian(4)
            result = result + messageLength
            
            var messageType :Array<UInt8> = [1 , 0 , 0, 0 ]
            result = result + messageType
            
            var payloadLength :Array<UInt8> = String(count(transaction.message.payload.utf16), radix: 16).asByteArrayEndian(4)
            result = result + payloadLength
            
            var payload :Array<UInt8> = transaction.message.payload.hexadecimalStringUsingEncoding(NSUTF8StringEncoding)!.asByteArray()
            result = result + payload
        }
        else
        {
            var messageLength :Array<UInt8> = [0 , 0 , 0 , 0]
            result = result + messageLength
        }
        
        return result
    }
    
    final class func importanceTransactionPart(transaction :ImportanceTransferTransaction)->Array<UInt8>
    {
        var result :Array<UInt8> = Array<UInt8>()
        
        var mode :Array<UInt8> =  String(transaction.mode, radix: 16).asByteArrayEndian(4)
        result = result + mode
        
        var lengthOfRemoutPublicKey :Array<UInt8> =  String(transaction.lengthOfRemoutPublicKey, radix: 16).asByteArrayEndian(4)
        result = result + lengthOfRemoutPublicKey
        
        var remoutPublicKey :Array<UInt8> =  transaction.remoutPublicKey.asByteArrayEndian(32)
        result = result + remoutPublicKey
        
        return result
    }
    
    final class func aggregateModificationTransactionPart(transaction :AggregateModificationTransaction)->Array<UInt8>
    {
        var result :Array<UInt8> = Array<UInt8>()
        
        var modificationsCount :Array<UInt8> = String(transaction.modifications.count, radix: 16).asByteArrayEndian(4)
        result = result + modificationsCount
        
        for modification in transaction.modifications
        {
            var lengthOfModification :Array<UInt8> = String(modification.lengthOfModification, radix: 16).asByteArrayEndian(4)
            result = result + lengthOfModification
            
            var modificationType :Array<UInt8> = String(modification.modificationType, radix: 16).asByteArrayEndian(4)
            result = result + modificationType
            
            var lengthOfPublicKey :Array<UInt8> = String(modification.lengthOfPublicKey, radix: 16).asByteArrayEndian(4)
            result = result + lengthOfPublicKey
            
            var publicKey :Array<UInt8> = modification.publicKey.asByteArrayEndian(32)
            result = result + publicKey

        }
        return result
    }
}

//01010000-01000068-00000000-20000000-8d07f90fb4bbe7715fa327c926770166a11be2e494a970605f2e12557f66c9b9-0000000000000000-00000000-28000000-4e414343483257504a59565133504c474d565a56524b354a4936504f544a5858484c55473350344a-60b94a948b320300-0d000000010000000500000048656c6c

//  01100000-01000098-f45f1000-20000000-dd13a7d3eec54e859617093f8221ab22357c9925ecdacd3321c7bc07148f9f67-c0d8a70000000000-0c751000-02000000-28000000-28 000000280000002800000028000000280000002800000028000000


