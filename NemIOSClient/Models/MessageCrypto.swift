import UIKit

class MessageCrypto: NSObject {
    final class func encrypt(message :String ,senderPrivateKey :String, recipientPublicKey :String) -> Array<UInt8> {
        
        let saltData = NSData().generateRandomIV(32)
        var saltBytes: Array<UInt8> = Array(count: 32, repeatedValue: 6) //Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(saltData.bytes), count: saltData.length))
        
        var sharedSecretBytes: Array<UInt8> = Array(count: 32, repeatedValue: 0)
        
        var senderPrivateKeyBytes: Array<UInt8> = senderPrivateKey.asByteArrayEndian(32)
        var recipientPublicKeyBytes: Array<UInt8> = recipientPublicKey.asByteArray()
        
        ed25519_key_exchange_nem(&sharedSecretBytes, &recipientPublicKeyBytes, &senderPrivateKeyBytes, &saltBytes)
        
        var messageBytes = message.hexadecimalStringUsingEncoding(NSUTF8StringEncoding)!.asByteArray()
        var messageData = NSData(bytes: &messageBytes, length: messageBytes.count)
        
        let ivData :Array<UInt8> = Array(count: 16, repeatedValue: 7)//NSData().generateRandomIV(16)
        let customizedIVBytes: Array<UInt8> = Array(count: 32, repeatedValue: 7)//Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(ivData.bytes), count: ivData.length))
        
        messageData = messageData.aesEncrypt(sharedSecretBytes, iv: ivData)!
        
        var encryptedBytes: Array<UInt8> = Array(count: 32, repeatedValue: 0)
        messageData.getBytes(&encryptedBytes, length: 32)
        
        let result = saltBytes + customizedIVBytes + encryptedBytes
        
        return result
    }

    final class func decrypt(messageBytes :Array<UInt8> ,recipientPrivateKey :String, senderPublicKey :String) -> String {
        
        var saltBytes :Array<UInt8> = Array(messageBytes[0..<32])
        let ivBytes :Array<UInt8> = Array(messageBytes[32..<48])
        var encBytes :Array<UInt8> = Array(messageBytes[48..<messageBytes.count])
     
        var recipientPrivateKeyBytes: Array<UInt8> = recipientPrivateKey.asByteArrayEndian(32)
        var senderPublicKeyBytes: Array<UInt8> = senderPublicKey.asByteArray()
        
        var sharedSecretBytes: Array<UInt8> = Array(count: 32, repeatedValue: 0)

        ed25519_key_exchange_nem(&sharedSecretBytes, &senderPublicKeyBytes, &recipientPrivateKeyBytes, &saltBytes)
        
        let messageData :NSData = NSData(bytes: &encBytes, length: encBytes.count)
        
        messageData.aesDecrypt(sharedSecretBytes, iv: ivBytes)
        
        var mes = NSString(data: messageData, encoding: NSUTF8StringEncoding)
        return messageData.hexadecimalString().stringFromHexadecimalStringUsingEncoding(NSUTF8StringEncoding) ?? ""
    }
    
    final class func getMessageStringFrom(message :MessageGetMetaData)-> String? {
        
        switch message.type {
        case 1:
            if message.payload.asByteArray().first == UInt8(0xfe) {
                return (message.payload as NSString).substringWithRange(NSRange(location: 2, length: message.payload.characters.count - 2))
            } else {
                return message.payload.stringFromHexadecimalStringUsingEncoding(NSUTF8StringEncoding)
            }
            
        case 2:
            return "encrypted message (not implemented)"
            
        default :
            return nil
        }
    }
}
