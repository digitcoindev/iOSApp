import UIKit

class ImportFromQR: AbstractViewController, QRDelegate
{
    //MARK: - IBOulets

    @IBOutlet weak var screenScaner: QR!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToImportFromQR
        State.currentVC = SegueToImportFromQR

        screenScaner.delegate = self
        
        titleLabel.text = "SCAN_QR_CODE".localized()
        
        if State.countVC <= 1{
            backButton.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        screenScaner.scanQR(screenScaner.frame.width , height: screenScaner.frame.height )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - IBAction
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToAddAccountVC)
        }
    }
    
    //MARK: - QRDelegate Methods
    
    func detectedQRWithString(text: String) {
        guard let jsonData = text.dataUsingEncoding(NSUTF8StringEncoding) else {
            screenScaner.play()
            return
        }
        var jsonStructure :NSDictionary? = (try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableLeaves)) as? NSDictionary

        if jsonStructure == nil {
            screenScaner.play()
        }
        else if jsonStructure!.objectForKey(QRKeys.DataType.rawValue) as! Int == QRType.AccountData.rawValue {
            jsonStructure = jsonStructure!.objectForKey(QRKeys.Data.rawValue) as? NSDictionary
            
            if jsonStructure != nil {
                let privateKey_AES = jsonStructure!.objectForKey(QRKeys.PrivateKey.rawValue) as! String
                let login = jsonStructure!.objectForKey(QRKeys.Name.rawValue) as! String
                let salt = jsonStructure!.objectForKey(QRKeys.Salt.rawValue) as! String
                let saltBytes = salt.asByteArray()
                let saltData = NSData(bytes: saltBytes, length: saltBytes.count)
                
                State.nextVC = SegueToLoginVC
                State.importAccountData = {
                    (password) -> Bool in
                    
                    guard let passwordHash :NSData? = try? HashManager.generateAesKeyForString(password, salt:saltData, roundCount:2000) else {return false}
                    print(passwordHash!.toHexString())
                    WalletGenerator().importWallet(login, password: passwordHash!.toHexString(), privateKey: privateKey_AES ,salt: salt)
                    return true
                }
                
                if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                    (self.delegate as! MainVCDelegate).pageSelected(SegueToPasswordValidation)
                }
            }
        }
        else {
            screenScaner.play()
        }
    }
}
