import UIKit

class AccountAddViewController: AbstractViewController
{
    //MARK: - IBOulets
    
    @IBOutlet weak var custom: UIButton!
    @IBOutlet weak var qr: UIButton!
    @IBOutlet weak var key: UIButton!

    //MARK: - Load Methods

    override func viewDidLoad(){
        super.viewDidLoad()
        
//        State.currentVC = SegueToAddAccountVC

        custom.layer.cornerRadius = 5
        qr.layer.cornerRadius = 5
        key.layer.cornerRadius = 5
        
        title = "ADD_ACCOUNT".localized()
        custom.setTitle("CREATE_NEW".localized(), forState: UIControlState.Normal)
        qr.setTitle("SCAN_QR_CODE".localized(), forState: UIControlState.Normal)
        key.setTitle("IMPORT_KEY".localized(), forState: UIControlState.Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        State.currentVC = SegueToAddAccountVC

    }
    
    override func delegateIsSetted() {
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - IBActions
    
    @IBAction func Custom(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToRegistrationVC)
        }
    }

    
    @IBAction func QR(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToImportFromQR)
        }
    }
    
    @IBAction func Key(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToImportFromKey)
        }
    }
}
