import UIKit

class KeyGenerator: NSObject
{
    final func generatePrivateKey()->String
    {
        var privateKeyBytes: Array<UInt8> = Array(count: 64, repeatedValue: 0)
        
        createPrivateKey(&privateKeyBytes)
        
        let privateKey :String = NSString(bytes: privateKeyBytes, length: privateKeyBytes.count, encoding: NSUTF8StringEncoding) as! String
        
        return privateKey
    }
    
    final func generatePublicKey(privateKey: String)->String
    {       
        var publicKeyBytes: Array<UInt8> = Array(count: 64, repeatedValue: 0)
        var privateKeyBytes: Array<UInt8> = Array(privateKey.utf8)
        println("pre")
        createPublicKey(&publicKeyBytes, &privateKeyBytes)
        println("aft")

        let publicKey :String = NSString(bytes: publicKeyBytes, length: publicKeyBytes.count, encoding: NSUTF8StringEncoding) as! String
        
        return publicKey

    }
}
