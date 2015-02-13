import UIKit
class WalletGenerator: NSObject
{
    let dataManager : CoreDataManager = CoreDataManager()

    func createWallet(login: String , password :String)
    {
        
        dataManager.addWallet(login, password: HashManager.AES256Encrypt(password) ,privateKey:  HashManager.AES256Encrypt( KeyGenerator().generatePrivateKey()))
    }
}
