import UIKit

class AddAccount: AbstractViewController
{
    //MARK: - IBOulets

    @IBOutlet weak var backButton: UIButton!
    
    //MARK: - Variables

    @IBOutlet weak var custom: UIButton!
    @IBOutlet weak var qr: UIButton!
    @IBOutlet weak var key: UIButton!

    //MARK: - Load Methods

    override func viewDidLoad(){
        super.viewDidLoad()
        
        State.fromVC = SegueToAddAccountVC
        State.currentVC = SegueToAddAccountVC

        custom.layer.cornerRadius = 5
        qr.layer.cornerRadius = 5
        key.layer.cornerRadius = 5
        
        if State.countVC <= 1{
            backButton.hidden = true
        }
    }
    
    override func delegateIsSetted() {
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - IBActions
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(State.lastVC)
        }
    }
    
    @IBAction func Custom(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object: SegueToRegistrationVC )
    }

    
    @IBAction func QR(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object: SegueToImportFromQR )
    }
    
    @IBAction func Key(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object: SegueToImportFromKey )
    }
}
