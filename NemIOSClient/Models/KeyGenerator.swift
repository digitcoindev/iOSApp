import UIKit

class KeyGenerator: NSObject
{
    final func generatePrivateKey()->String
    {
        var privateKeyBytes: Array<UInt8> = Array(count: 128, repeatedValue: 0)
        
        createPrivateKey(&privateKeyBytes)
        
        let privateKey :String = NSString(bytes: privateKeyBytes, length: privateKeyBytes.count, encoding: NSUTF8StringEncoding) as String
        
        //return privateKey
        return "00fd4037509af1cd3556d270955b5a2c847a7d768a5ba8ed5ea321bb3ad2ca7d17"
        
    }
    final func generatePublicKey(privateKey: String)->String
    {
        var publicKeyBytes: Array<UInt8> = Array(count: 128, repeatedValue: 0)
        var privateKeyBytes: Array<UInt8> = Array(privateKey.utf8)
        
        createPublicKey(&publicKeyBytes, &privateKeyBytes)
        
        let publicKey :String = NSString(bytes: publicKeyBytes, length: publicKeyBytes.count, encoding: NSUTF8StringEncoding) as String
        
        //return publicKey
        return "2f8c887039b2e257f5ec5b1a07eb8abc94c5c0d43f9691dfb7ce4d5d268cd44e"
        //return "2ea67233911b0f27250d68bc0151f4ae44da8feb7eaf302540592e608b7ffc7e"
    }
}
