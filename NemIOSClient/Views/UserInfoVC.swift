import UIKit

class UserInfoVC: AbstractViewController
{

    @IBOutlet weak var qrImg: UIImageView!
    @IBOutlet weak var keyLable: UILabel!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        if State.fromVC != SegueToUserInfo
        {
            State.fromVC = SegueToUserInfo
        }
        
        State.currentVC = SegueToUserInfo
        
        var privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        var publicKey = KeyGenerator().generatePublicKey(privateKey)
        var address :String = AddressGenerator().generateAddress(publicKey)
        
        keyLable.text = address
                
        var jsonFriendDictionary :NSDictionary = NSDictionary(objects: [address, State.currentWallet!.login], forKeys: ["address", "name"])
        var jsonDictionary :NSDictionary = NSDictionary(objects: [1, jsonFriendDictionary], forKeys: ["type", "data"])
        var jsonData :NSData = NSJSONSerialization.dataWithJSONObject(jsonDictionary, options: NSJSONWritingOptions.allZeros, error: nil)!
        var base64String :String = jsonData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
        var qr :QR = QR()
        qrImg.image =  qr.createQR(base64String)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()

    }


}
