import UIKit

class CreateQRInput: UIViewController
{
    @IBOutlet weak var amount: UITextField!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if State.fromVC != SegueToCreateQRInput
        {
            State.fromVC = SegueToCreateQRInput
        }
        
        State.currentVC = SegueToCreateQRInput
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    @IBAction func confirm(sender: AnyObject)
    {
        if amount.text.toInt() != nil
        {
            State.amount = amount.text.toInt()!
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToCreateQRResult )
        
    }
    
}
