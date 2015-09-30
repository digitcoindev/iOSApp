import UIKit

class UserInfoVC: AbstractViewController
{

    @IBOutlet weak var qrImg: UIImageView!
    @IBOutlet weak var keyLable: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if State.fromVC != SegueToUserInfo {
            State.fromVC = SegueToUserInfo
        }
        
        State.currentVC = SegueToUserInfo
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        let publicKey = KeyGenerator.generatePublicKey(privateKey)
        let address :String = AddressGenerator.generateAddress(publicKey)
        
        keyLable.text = address
                
        let jsonFriendDictionary :NSDictionary = NSDictionary(objects: [address, State.currentWallet!.login], forKeys: ["address", "name"])
        let jsonDictionary :NSDictionary = NSDictionary(objects: [1, jsonFriendDictionary], forKeys: ["type", "data"])
        let jsonData :NSData = try! NSJSONSerialization.dataWithJSONObject(jsonDictionary, options: NSJSONWritingOptions())
        let base64String :String = jsonData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        let qr :QR = QR()
        qrImg.image =  qr.createQR(base64String)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }


}
