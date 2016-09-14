import UIKit

class MessageCrypto: NSObject {
    final class func encrypt(_ message :[UInt8] ,senderPrivateKey :String, recipientPublicKey :String) -> Array<UInt8> {
        
        let saltData = (Data() as NSData).generateRandomIV(32)
        var saltBytes: Array<UInt8> = Array(UnsafeBufferPointer(start: saltData!.bytes.bindMemory(to: UInt8.self, capacity: saltData!.count), count: saltData!.count))
        
        var sharedSecretBytes: [UInt8] = Array(repeating: 0, count: 32)
        
        var senderPrivateKeyBytes: Array<UInt8> = senderPrivateKey.asByteArrayEndian(32)
        var recipientPublicKeyBytes: Array<UInt8> = recipientPublicKey.asByteArray()
        
        ed25519_key_exchange_nem(&sharedSecretBytes, &recipientPublicKeyBytes, &senderPrivateKeyBytes, &saltBytes)
        
        var messageBytes = message
        var messageData = Data(bytes: UnsafePointer<UInt8>(&messageBytes), count: messageBytes.count)
        
        let ivData = (Data() as NSData).generateRandomIV(16)
        let customizedIVBytes: Array<UInt8> = Array(UnsafeBufferPointer(start: ivData!.bytes.bindMemory(to: UInt8.self, capacity: ivData!.count), count: ivData!.count))
        messageData = messageData.aesEncrypt(sharedSecretBytes, iv: customizedIVBytes)!
        var encryptedBytes: Array<UInt8> = Array(repeating: 0, count: messageData.count)
        (messageData as NSData).getBytes(&encryptedBytes, length: messageData.count)
        let result = saltBytes + customizedIVBytes + encryptedBytes
        
        return result
    }

    final class func decrypt(_ messageBytes :Array<UInt8> ,recipientPrivateKey :String, senderPublicKey :String) -> String? {
        
        var saltBytes :Array<UInt8> = Array(messageBytes[0..<32])
        let ivBytes :Array<UInt8> = Array(messageBytes[32..<48])
        var encBytes :Array<UInt8> = Array(messageBytes[48..<messageBytes.count])

        var recipientPrivateKeyBytes: Array<UInt8> = recipientPrivateKey.asByteArrayEndian(32)
        var senderPublicKeyBytes: Array<UInt8> = senderPublicKey.asByteArray()
        
        var sharedSecretBytes: Array<UInt8> = Array(repeating: 0, count: 32)

        ed25519_key_exchange_nem(&sharedSecretBytes, &senderPublicKeyBytes, &recipientPrivateKeyBytes, &saltBytes)
        
        var messageData :Data? = Data(bytes: UnsafePointer<UInt8>(&encBytes), count: encBytes.count)
        
        messageData = messageData?.aesDecrypt(sharedSecretBytes, iv: ivBytes)
        
        if messageData == nil {
            return nil
        }
        return NSString(data: messageData!, encoding: String.Encoding.utf8.rawValue) as? String
    }
}
