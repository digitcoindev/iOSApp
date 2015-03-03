import UIKit

class DashboardVC: UIViewController
{
    @IBOutlet weak var Messages: UIButton!
    @IBOutlet weak var AddFriend: UIButton!
    @IBOutlet weak var CreateQR: UIButton!
    @IBOutlet weak var UserInfo: UIButton!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        State.currentVC = SegueToDashboard
        
    }
    
    override func viewDidAppear(animated: Bool)
    {
        self.Messages.imageEdgeInsets = UIEdgeInsetsMake(15, self.Messages.bounds.width / 2 - 20, 25, self.Messages.bounds.width / 2 - 20)
        self.AddFriend.imageEdgeInsets = UIEdgeInsetsMake(15, self.AddFriend.bounds.width / 2 - 20, 25, self.AddFriend.bounds.width / 2 - 20)
        self.CreateQR.imageEdgeInsets = UIEdgeInsetsMake(15, self.CreateQR.bounds.width / 2 - 20, 25, self.CreateQR.bounds.width / 2 - 20)
        self.UserInfo.imageEdgeInsets = UIEdgeInsetsMake(15, self.UserInfo.bounds.width / 2 - 20, 25, self.UserInfo.bounds.width / 2 - 20)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func createQR(sender: AnyObject)
    {
        NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToCreateQRInput )

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
