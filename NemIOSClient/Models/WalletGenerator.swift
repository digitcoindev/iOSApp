import UIKit
class WalletGenerator: NSObject
{
    let dataManager : CoreDataManager = CoreDataManager()

    final func createWallet(login: String , password :String , privateKey :String? = nil) {
        var privateKeyString :String? = privateKey
        
        if privateKeyString == nil {
            privateKeyString = KeyGenerator.generatePrivateKey()
        }
        
        let privateKeyHash :String = HashManager.AES256Encrypt(privateKeyString!)

        let salt :NSData = HashManager.salt(length: 64)
        
        let passwordHash :NSData? = try? HashManager.generateAesKeyForString(password, salt:salt, roundCount:2000)!
        
        dataManager.addWallet(login, password: passwordHash!.toHexString() ,privateKey: privateKeyHash, salt:salt.toHexString() )

    }
    
    final func importWallet(login: String , password :String , privateKey :String , salt :String) {
        dataManager.addWallet(login, password: password ,privateKey: privateKey, salt: salt)
    }
}
