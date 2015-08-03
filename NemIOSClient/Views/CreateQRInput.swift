import UIKit

class CreateQRInput: AbstractViewController
{
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var message: NEMTextField!
    @IBOutlet weak var name: NEMTextField!
    @IBOutlet weak var amount: UITextField!
    
    var showRect :CGRect = CGRectZero

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if State.fromVC != SegueToCreateQRInput
        {
            State.fromVC = SegueToCreateQRInput
        }
        
        State.currentVC = SegueToCreateQRInput
        
        var observer: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        observer.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        observer.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    @IBAction func hideKeyboard(sender: AnyObject)
    {
        if name.text == ""
        {
            name.becomeFirstResponder()
        }
        else if amount.text == ""
        {
            amount.becomeFirstResponder()
        }
        else if message.text == ""
        {
            message.becomeFirstResponder()
        }
        else
        {
            
        }
        
        sender.becomeFirstResponder()
    }
    
    @IBAction func confirm(sender: AnyObject)
    {
        var canCreate :Bool = true
        
        if amount.text.toInt() == nil
        {
            canCreate = false
            amount.text = ""
        }
        
        if name.text == ""
        {
            canCreate = false
        }
        
        if canCreate
        {
            var invoice :InvoiceData = InvoiceData()
            invoice.name = name.text
            invoice.message = message.text
            invoice.address = AddressGenerator().generateAddressFromPrivateKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey))
            invoice.amount = amount.text.toInt()
            invoice.number = Int(CoreDataManager().addInvoice(invoice).number)
            
            
            State.invoice = invoice

            NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToCreateQRResult )
            
        }
    }
    
    @IBAction func touchDown(sender: AnyObject)
    {
        showRect = sender.frame
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        var info:NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        var animationDuration = 0.1
        
        keyboardHeight -= self.view.frame.height - self.scroll.frame.height
        
        self.scroll.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight , 0)
        self.scroll.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.scroll.scrollRectToVisible(showRect, animated: true)
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        self.scroll.contentInset = UIEdgeInsetsZero
        self.scroll.scrollIndicatorInsets = UIEdgeInsetsZero
    }
}
