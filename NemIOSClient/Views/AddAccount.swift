import UIKit

class AddAccount: UIViewController
{

    @IBOutlet weak var custom: UIButton!
    @IBOutlet weak var qr: UIButton!
    @IBOutlet weak var key: UIButton!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if State.fromVC != SegueToAddAccountVC
        {
            State.fromVC = SegueToAddAccountVC
        }
        
        State.currentVC = SegueToAddAccountVC

        custom.layer.cornerRadius = 2
        
        qr.layer.cornerRadius = 2
        key.layer.cornerRadius = 2
        
        NSNotificationCenter.defaultCenter().postNotificationName("Title", object:"" )
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func Custom(sender: AnyObject)
    {
        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object: SegueToRegistrationVC )
    }

    
    @IBAction func QR(sender: AnyObject)
    {
        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object: SegueToImportFromQR )
    }
    
    @IBAction func Key(sender: AnyObject)
    {
        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object: SegueToImportFromKey )
    }
    
}
