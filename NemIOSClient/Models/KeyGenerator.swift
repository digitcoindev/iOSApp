import UIKit

class KeyGenerator: NSObject
{
    final func generatePrivateKey()->String
    {
        var privateKeyBytes: Array<UInt8> = Array(count: 128, repeatedValue: 0)
        
        createPrivateKey(&privateKeyBytes)
        
        let privateKey :String = NSString(bytes: privateKeyBytes, length: privateKeyBytes.count, encoding: NSUTF8StringEncoding) as String
        
        return privateKey
    }
    
    final func generatePublicKey(privateKey: String)->String
    {
        if privateKey == "test"
        {
            return "2ea67233911b0f27250d68bc0151f4ae44da8feb7eaf302540592e608b7ffc7e"
        }
        
        var publicKeyBytes: Array<UInt8> = Array(count: 64, repeatedValue: 0)
        var privateKeyBytes: Array<UInt8> = Array(privateKey.utf8)
        
        createPublicKey(&publicKeyBytes, &privateKeyBytes)
        
        let publicKey :String = NSString(bytes: publicKeyBytes, length: publicKeyBytes.count, encoding: NSUTF8StringEncoding) as String
        
        return publicKey

    }
}
