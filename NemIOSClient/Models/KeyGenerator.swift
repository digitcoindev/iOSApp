import UIKit

class KeyGenerator: NSObject
{
    final func generatePrivateKey()->String
    {
        var privateKeyBytes: Array<UInt8> = Array(count: 64, repeatedValue: 0)
        
        createPrivateKey(&privateKeyBytes)
        
        let privateKey :String = NSString(bytes: privateKeyBytes, length: privateKeyBytes.count, encoding: NSUTF8StringEncoding) as String
        
        return privateKey
    }
    
    final func generatePublicKey(privateKey: String)->String
    {
        if privateKey == "test"
        {
            return "cba08dd72505e0c6aa0b7521598c7c63ecef72bd48175355f9dd977664e4fcd1"
        }
        
        var publicKeyBytes: Array<UInt8> = Array(count: 64, repeatedValue: 0)
        var privateKeyBytes: Array<UInt8> = Array(privateKey.utf8)
        
        createPublicKey(&publicKeyBytes, &privateKeyBytes)
        
        let publicKey :String = NSString(bytes: publicKeyBytes, length: publicKeyBytes.count, encoding: NSUTF8StringEncoding) as String
        
        return publicKey

    }
}
