import UIKit

class MessageCrypto: NSObject {
    final class func encrypt(message :String ,senderPrivateKey :String, recipientPublicKey :String) -> Array<UInt8> {
        let saltData = HashManager.salt(length: 32)
        var saltBytes: Array<UInt8> = "872860a4e45343f353c2597af8b2a87e1450d6e5e5eeb529a049ffef648abd33".asByteArrayEndian(32)
        saltData.getBytes(&saltBytes, length: 32)
        
        var sharedSecretBytes: Array<UInt8> = Array(count: 32, repeatedValue: 0)
        
        var senderPrivateKeyBytes: Array<UInt8> = senderPrivateKey.asByteArray()
        var recipientPublicKeyBytes: Array<UInt8> = recipientPublicKey.asByteArray()
        
        ed25519_key_exchange(&sharedSecretBytes, &recipientPublicKeyBytes, &senderPrivateKeyBytes)
        
        for var index = 0 ; index < sharedSecretBytes.count ; index++ {
            sharedSecretBytes[index] ^= saltBytes[index]
        }
        
        let sharedSecretData  = NSData(bytes: &sharedSecretBytes, length: 32)
        let sharedSecretSHA256 = HashManager().SHA256Encrypt(sharedSecretData.hexadecimalString())
        
        var messageBytes = message.hexadecimalStringUsingEncoding(NSUTF8StringEncoding)!.asByteArray()
        let messageData = NSData(bytes: &messageBytes, length: messageBytes.count)
        
        //var randomIV =  NSData().generateRandomIV(11).base64EncodingWithLineLength(0)
        let customizedIV =  "480cf91a6ac0597641db41111f9f3c75"
        let customizedIVBytes: Array<UInt8> = customizedIV.asByteArray()
        
        messageData.AES256EncryptWithKey(sharedSecretSHA256, iv: customizedIV)
        
        var encryptedBytes: Array<UInt8> = Array(count: 32, repeatedValue: 0)
        messageData.getBytes(&encryptedBytes, length: 32)
        
        let result = saltBytes + customizedIVBytes + encryptedBytes
        
        return result
    }

    final class func decrypt(messageBytes :Array<UInt8> ,recipientPrivateKey :String, senderPublicKey :String) -> String {
        
        
        let saltBytes :Array<UInt8> = Array(messageBytes[0..<32])
        var ivBytes :Array<UInt8> = Array(messageBytes[32..<48])
        var encBytes :Array<UInt8> = Array(messageBytes[48..<messageBytes.count])
     
        var recipientPrivateKeyBytes: Array<UInt8> = recipientPrivateKey.asByteArray()
        var senderPublicKeyBytes: Array<UInt8> = senderPublicKey.asByteArray()
        
        var sharedSecretBytes: Array<UInt8> = Array(count: 32, repeatedValue: 0)

        ed25519_key_exchange(&sharedSecretBytes, &senderPublicKeyBytes, &recipientPrivateKeyBytes)

        for var index = 0 ; index < sharedSecretBytes.count ; index++ {
            sharedSecretBytes[index] ^= saltBytes[index]
        }
        
        let messageData :NSData = NSData(bytes: &encBytes, length: 32)
        let sharedSecretData :NSData = NSData(bytes: &sharedSecretBytes, length: 32)
        let ivData :NSData = NSData(bytes: &ivBytes, length: 32)
        messageData.AES256DecryptWithKey(sharedSecretData.hexadecimalString(), iv: ivData.hexadecimalString())
        
        
        return messageData.hexadecimalString().stringFromHexadecimalStringUsingEncoding(NSUTF8StringEncoding)!
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
