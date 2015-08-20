import UIKit

class KeyGenerator: NSObject
{
    final class func generatePrivateKey()->String {
        var privateKeyBytes: Array<UInt8> = Array(count: 32, repeatedValue: 0)
        
        createPrivateKey(&privateKeyBytes)
        
        let privateKey :String = NSData(bytes: &privateKeyBytes, length: 32).toHexString()
        
        return privateKey
    }
    
    final class func generatePublicKey(privateKey: String)->String {       
        var publicKeyBytes: Array<UInt8> = Array(count: 32, repeatedValue: 0)
        var privateKeyBytes: Array<UInt8> = privateKey.asByteArrayEndian(32)
        
        createPublicKey(&publicKeyBytes, &privateKeyBytes)
        
        let publicKey :String = NSData(bytes: &publicKeyBytes, length: 32).toHexString()

        return publicKey

    }
}
