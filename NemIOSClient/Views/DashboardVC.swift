import UIKit

class DashboardVC: UIViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        State.currentVC = SegueToDashboard
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func createQR(sender: AnyObject)
    {
        var alert :UIAlertView = UIAlertView(title: "Info", message: "Currently unavailable.\nIn developing process.", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    
    @IBAction func sandMessage(sender: AnyObject)
    {
        NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToMessages )

    }
    
    @IBAction func scanQR(sender: AnyObject)
    {
        var alert :UIAlertView = UIAlertView(title: "Info", message: "Currently unavailable.\nIn developing process.", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }

    @IBAction func userInfo(sender: AnyObject)
    {
        NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToUserInfo )
    }
}
