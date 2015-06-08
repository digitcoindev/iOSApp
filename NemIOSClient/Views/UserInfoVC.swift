import UIKit

class UserInfoVC: UIViewController
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
        
        var name_surmane = split(State.currentWallet!.login) {$0 == " "}
        var name :String = ""
        var surname :String = ""
        for var i = 0 ; i < name_surmane.count ; i++
        {
            if i != name_surmane.count - 1
            {
                name += name_surmane[i]
            }
            else
            {
                surname += name_surmane[i]
            }
        }
        
        var jsonFriendDictionary :NSDictionary = NSDictionary(objects: [address, name, surname], forKeys: ["address", "name", "surname"])
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
