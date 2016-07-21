import UIKit
class WalletGenerator: NSObject
{
    let dataManager : CoreDataManager = CoreDataManager()

    final func createWallet(login: String, privateKey :String? = nil) {
        var privateKeyString :String? = privateKey
        
        if privateKeyString == nil {
            privateKeyString = KeyGenerator.generatePrivateKey()
        }
        
        let passwordHash :NSData? = NSData(bytes: State.loadData!.password!.asByteArray())
        let privateKeyHash :String = HashManager.AES256Encrypt(privateKeyString!, key: passwordHash!.toHexString())

        dataManager.addWallet(login, privateKey: privateKeyHash)
    }
}
