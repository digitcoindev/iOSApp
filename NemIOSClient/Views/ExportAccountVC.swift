import UIKit
import Social
import MessageUI

class ExportAccountVC: AbstractViewController , MFMailComposeViewControllerDelegate
{
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var privateKey: UITextView!
    @IBOutlet weak var publicKey: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var publicKeyLabel: UILabel!
    @IBOutlet weak var showPrivateKeyButn: UIButton!
    
    private var popup :AbstractViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let qr :QR = QR()
        
        qrImage.image =  qr.createQR(State.exportAccount!)
        
        let priv_key = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
        let pub_key = KeyGenerator.generatePublicKey(priv_key!)
        privateKey.text = priv_key
        publicKey.text = pub_key
        
        shareButton.setTitle("SHARE_QR".localized(), forState: UIControlState.Normal)
        copyButton.setTitle("SAVE_QR".localized(), forState: UIControlState.Normal)
        titleLabel.text = "EXPORT_ACCOUNT".localized()
        publicKeyLabel.text = "PUBLIC_KEY".localized()
        showPrivateKeyButn.setTitle("VIEW_PRIVATE_KEY".localized(), forState: UIControlState.Normal)
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.view.endEditing(true)
        State.currentVC = SegueToExportAccount
    }
    
    @IBAction func showPrivateKey(sender: AnyObject) {
        self.view.endEditing(true)
        
        if  !privateKey.hidden {
            showPrivateKeyButn.setTitle("VIEW_PRIVATE_KEY".localized(), forState: UIControlState.Normal)
            privateKey.hidden = true
        } else {
            if popup != nil {
                popup!.view.removeFromSuperview()
                popup!.removeFromParentViewController()
                popup = nil
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let popUpController :AbstractViewController =  storyboard.instantiateViewControllerWithIdentifier("PrivateKey warning") as! AbstractViewController
            popUpController.view.frame = CGRect(x: 0, y: 40, width: popUpController.view.frame.width, height: popUpController.view.frame.height - 40)
            popUpController.view.layer.opacity = 0
            popUpController.delegate = self
            
            popup = popUpController
            self.view.addSubview(popUpController.view)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                popUpController.view.layer.opacity = 1
                }, completion: nil)
        }
    }
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToMainMenu)
        }
    }
    
    @IBAction func copyQR(sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(qrImage.image!, nil, nil, nil)
    }
    
    @IBAction func shareQR(sender: AnyObject) {
        self.view.endEditing(true)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let shareVC :ShareViewController =  storyboard.instantiateViewControllerWithIdentifier("SharePopUp") as! ShareViewController
        shareVC.view.frame = CGRect(x: 0, y: 0, width: shareVC.view.frame.width, height: shareVC.view.frame.height)
        shareVC.view.layer.opacity = 0
        shareVC.delegate = self
        
        shareVC.images = [qrImage.image!]
        popup = shareVC
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.view.addSubview(shareVC.view)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                shareVC.view.layer.opacity = 1
                }, completion: nil)
        })
    }
}
