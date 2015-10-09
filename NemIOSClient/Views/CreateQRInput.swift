import UIKit

class CreateQRInput: AbstractViewController
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var message: NEMTextField!
    @IBOutlet weak var name: NEMTextField!
    @IBOutlet weak var amount: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToCreateInvoice
        State.currentVC = SegueToCreateInvoice
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
        var canCreate :Bool = true
        
        if Int(amount.text!) == nil {
            canCreate = false
            amount.text = ""
        }
        
        if name.text == "" {
            canCreate = false
        }
        
        if canCreate {
            var invoice :InvoiceData = InvoiceData()
            invoice.name = name.text
            invoice.message = message.text
            invoice.address = AddressGenerator.generateAddressFromPrivateKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey))
            invoice.amount = Int(amount.text!)
            invoice.number = Int(CoreDataManager().addInvoice(invoice).number)
            
            State.invoice = invoice

            if self.delegate != nil && self.delegate!.respondsToSelector("changePage:") {
                (self.delegate as! QRViewController).changePage(SegueToCreateInvoiceResult)
            }
        }
    }
}
