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
        var address  = AddressGenerator().generateAddress(publicKey)
        
        keyLable.text = address as String
        
        var qr :QR = QR()
        qrImg.image =  qr.createQR(keyLable.text!)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()

    }


}
