import UIKit

class CreateQRResult: UIViewController
{
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var xems: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if State.fromVC != SegueToCreateQRResult
        {
            State.fromVC = SegueToCreateQRResult
        }
        
        State.currentVC = SegueToCreateQRResult
        
        xems.text = "\(State.amount)" + " XEM"
        
        var privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        var publicKey = KeyGenerator().generatePublicKey(privateKey)
        
        address.text = publicKey as String
        
        var qr :QR = QR()
        var qrText :String = "{\"address\":\"\(address.text!)\",\"amount\":\"\(State.amount)\"}"
        
        qrImage.image =  qr.createQR(qrText)

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

}
