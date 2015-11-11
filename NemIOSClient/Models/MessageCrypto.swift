import UIKit

class MessageCrypto: NSObject {
    final class func encrypt(message :[UInt8] ,senderPrivateKey :String, recipientPublicKey :String) -> Array<UInt8> {
        
        let saltData = NSData().generateRandomIV(32)
        var saltBytes: Array<UInt8> = Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(saltData.bytes), count: saltData.length))
        
        var sharedSecretBytes: [UInt8] = Array(count: 32, repeatedValue: 0)
        
        var senderPrivateKeyBytes: Array<UInt8> = senderPrivateKey.asByteArrayEndian(32)
        var recipientPublicKeyBytes: Array<UInt8> = recipientPublicKey.asByteArray()
        
        ed25519_key_exchange_nem(&sharedSecretBytes, &recipientPublicKeyBytes, &senderPrivateKeyBytes, &saltBytes)
        
        var messageBytes = message
        var messageData = NSData(bytes: &messageBytes, length: messageBytes.count)
        
        let ivData = NSData().generateRandomIV(16)
        let customizedIVBytes: Array<UInt8> = Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(ivData.bytes), count: ivData.length))
        messageData = messageData.aesEncrypt(sharedSecretBytes, iv: customizedIVBytes)!
        var encryptedBytes: Array<UInt8> = Array(count: messageData.length, repeatedValue: 0)
        messageData.getBytes(&encryptedBytes, length: messageData.length)
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
        
        var messageData :NSData = NSData(bytes: &encBytes, length: encBytes.count)
        
        messageData = messageData.aesDecrypt(sharedSecretBytes, iv: ivBytes)!
        
        return (NSString(data: messageData, encoding: NSUTF8StringEncoding) as? String) ?? "Could not decrypt"
    }
}
