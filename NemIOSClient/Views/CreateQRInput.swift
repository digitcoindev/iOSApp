import UIKit

class CreateQRInput: AbstractViewController
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var message: NEMTextField!
    @IBOutlet weak var name: NEMTextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var createButton: UIButton!

    private let _dataManager = CoreDataManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        amount.placeholder = "ENTER_AMOUNT".localized()
        name.placeholder = "ENTER_NAME".localized()
        message.placeholder = "ENTER_MESSAGE".localized()
        
        createButton.setTitle("CREATE".localized(), forState: UIControlState.Normal)
        
        State.currentVC = SegueToCreateInvoice
        
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        
        let loadData = State.loadData
        
        name.text = State.currentWallet?.login ?? ""
        message.text =  ""
        
        if let prefix = loadData?.invoicePrefix {
            message.text = prefix
        }
        
        message.text = message.text! + "/\(_dataManager.getInvoice().count)/"
        
        if let postfix = loadData?.invoicePostfix {
            message.text = message.text! + postfix
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func hideKeyboard(sender: AnyObject) {
        if name.text == "" {
            name.becomeFirstResponder()
        }
        else if amount.text == "" {
            amount.becomeFirstResponder()
        }
        else if message.text == "" {
            message.becomeFirstResponder()
        }
    }
    
    @IBAction func confirm(sender: AnyObject) {
        
        if Int(amount.text!) == nil {
            amount.text = ""
            return
        }
        
        if name.text == "" {
            return
        }
        
        if message.text?.hexadecimalStringUsingEncoding(NSUTF8StringEncoding)?.asByteArray().count > 255 {
            let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: "MESSAGE_LENGTH".localized(), preferredStyle: UIAlertControllerStyle.Alert)
            
            let ok :UIAlertAction = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default) {
                alertAction -> Void in
                
                if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                    (self.delegate as! MainVCDelegate).pageSelected(SegueToUnconfirmedTransactionVC)
                }
            }
            alert.addAction(ok)
            
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        var invoice :InvoiceData = InvoiceData()
        invoice.name = name.text
        invoice.message = message.text
        invoice.address = AddressGenerator.generateAddressFromPrivateKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)!)
        invoice.amount = (Double(amount.text!) ?? 0) * 1000000
        invoice.number = Int(CoreDataManager().addInvoice(invoice).number)
        CoreDataManager().commit()
        State.invoice = invoice
        
        if self.delegate != nil && self.delegate!.respondsToSelector("changePage:") {
            (self.delegate as! QRViewController).changePage(SegueToCreateInvoiceResult)
        }
    }
}
