import UIKit
class WalletGenerator: NSObject
{
//    let dataManager : CoreDataManager = CoreDataManager()

    final func createWallet(_ login: String, privateKey :String? = nil) {
        var privateKeyString :String? = privateKey
        
//        if privateKeyString == nil {
//            privateKeyString = KeyGenerator.generatePrivateKey()
//        }
        
        let passwordHash :Data? = Data(bytes: State.loadData!.password!.asByteArray())
        let privateKeyHash :String = HashManager.AES256Encrypt(inputText: privateKeyString!, key: passwordHash!.toHexString())

//        dataManager.addWallet(login, privateKey: privateKeyHash)
    }
}
