//import UIKit
//
//class KeyGenerator: NSObject
//{
//    final class func generatePrivateKey()->String {
//        var privateKeyBytes: Array<UInt8> = Array(repeating: 0, count: 32)
//        
//        createPrivateKey(&privateKeyBytes)
//        
//        let privateKey :String = Data(bytes: UnsafePointer<UInt8>(&privateKeyBytes), count: 32).toHexString()
//        
//        return privateKey
//    }
//    
//    final class func generatePublicKey(_ privateKey: String)->String {       
//        var publicKeyBytes: Array<UInt8> = Array(repeating: 0, count: 32)
//        var privateKeyBytes: Array<UInt8> = privateKey.asByteArrayEndian(privateKey.asByteArray().count)
//        
//        createPublicKey(&publicKeyBytes, &privateKeyBytes)
//        
//        let publicKey :String = Data(bytes: UnsafePointer<UInt8>(&publicKeyBytes), count: 32).toHexString()
//
//        return publicKey
//    }
//}
