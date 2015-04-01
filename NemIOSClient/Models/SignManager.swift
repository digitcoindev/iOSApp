import UIKit

class SignManager: NSObject
{
    final class func signTransaction(transaction :TransactionPostMetaData)->SignedTransactionMetaData
    {
        var signedTransaction :SignedTransactionMetaData = SignedTransactionMetaData()
        
        var array = SignManager.dataGeneration(transaction)
        var toString = ""
        
        for value in array
        {
            toString = toString + NSString(format: "%02x", value)
        }
        
        signedTransaction.dataT = toString
        
        toString = ""
        array = SignManager.signatureGeneration(array, transaction: transaction)
        
        for value in array
        {
            toString = toString + NSString(format: "%02x", value)
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
        
        var output :String = String()
        
        for value in signature
        {
            output = output + NSString(format: "%02x", value)
        }
        
        println(output)
        
        return signature
    }
    
    final class func dataGeneration(transaction :TransactionPostMetaData)->Array<UInt8>
    {
        var result :Array<UInt8> = Array<UInt8>()
        
        var transactionType :Array<UInt8>  = [1 , 1 , 0 , 0]
        result = result + transactionType
        
        var version :Array<UInt8> = [1 , 0 , 0, 0 ]
        result = result + version
        
        var timeStamp :Array<UInt8> = String(Int64(transaction.timeStamp), radix: 16).asByteArrayIndian(4)
        result = result + timeStamp
        
        var publicKeyLength :Array<UInt8> = [32 , 0 , 0 , 0]
        result = result + publicKeyLength
        
        var publicKey :Array<UInt8> = transaction.signer.asByteArray()
        result = result + publicKey
        
        var fee :Array<UInt8> = String(Int64(transaction.fee * 1000000), radix: 16).asByteArrayIndian(8)
        result = result + fee
        
        var deadline :Array<UInt8> = String(Int64(transaction.deadline), radix: 16).asByteArrayIndian(4)
        result = result + deadline
        
        var addressLength :Array<UInt8> = [40 , 0 , 0 , 0]
        result = result + addressLength
        
        var address :Array<UInt8> = Array<UInt8>(transaction.recipient.utf8)
        result = result + address
        
        var amount = String(Int64(transaction.amount * 1000000), radix: 16).asByteArrayIndian(8)
        result = result + amount
        
        if transaction.message.payload != ""
        {
            var length :Int = transaction.message.payload.utf16Count + 8
            var messageLength :Array<UInt8> = String(length, radix: 16).asByteArrayIndian(4)
            result = result + messageLength
            
            var messageType :Array<UInt8> = [1 , 0 , 0, 0 ]
            result = result + messageType
            
            var payloadLength :Array<UInt8> = String(transaction.message.payload.utf16Count, radix: 16).asByteArrayIndian(4)
            result = result + payloadLength
            
            var payload :Array<UInt8> = transaction.message.payload.hexadecimalStringUsingEncoding(NSUTF8StringEncoding)!.asByteArray()
            result = result + payload
        }
        else
        {
            var messageLength :Array<UInt8> = [0 , 0 , 0 , 0]
            result = result + messageLength
        }
        
        var output :String = String()
        
        for value in result
        {
            if value > 127
            {
                output = output + "\(value - 200 - 56) ,"
            }
            else
            {
                output = output + "\(value) ,"
            }
        }
        
        println(output)
        return result
    }
}


//01010000-01000000-099c0400-20000000-d1fce4647697ddf955531748bd72efec637c8c5921750baac6e00525d78da0cb-001bb70000000000-19c30400-28000000-5443494e56504b52593358323452514d43575a4c4545424a515533475a464b435257364e4b343659-8096980000000000-00000000
////01010000-01000000-099c0400-20000000-20000000001bb7000000000019c30400280000005443494e56504b52593358323452514d43575a4c4545424a515533475a464b435257364e4b343659809698000000000000000000
//01010000-01000068-00000000-20000000-8d07f90fb4bbe7715fa327c926770166a11be2e494a970605f2e12557f66c9b9-0000000000000000-00000000-28000000-4e414343483257504a59565133504c474d565a56524b354a4936504f544a5858484c55473350344a-60b94a948b320300-0d000000010000000500000048656c6c




