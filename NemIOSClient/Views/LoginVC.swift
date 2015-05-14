import UIKit

class LoginVC: UIViewController , UITableViewDelegate
{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addWallet: UIButton!
    
    let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()
    var timer :NSTimer!
    var state :[String] = ["none"]
    
    var dataManager :CoreDataManager = CoreDataManager()
    var apiManager :APIManager = APIManager()
    
    var wallets :[Wallet] = [Wallet]()
    var selectedIndex :Int  = -1
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
                
        wallets  = dataManager.getWallets()
        
        if State.fromVC != SegueToLoginVC
        {
            State.fromVC = SegueToLoginVC
        }
                
        State.currentVC = SegueToLoginVC
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.layer.cornerRadius = 5
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        
        observer.addObserver(self, selector: "logIn:", name: "heartbeatSuccessed", object: nil)
        observer.addObserver(self, selector: "serverDenied:", name: "heartbeatDenied", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("Title", object:"Accounts")
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didMoveToParentViewController(parent: UIViewController?)
    {
        if parent == nil
        {
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addNewWallet(sender: AnyObject)
    {
        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object: SegueToAddAccountVC )
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return wallets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : WalletCell = self.tableView.dequeueReusableCellWithIdentifier("walletCell") as! WalletCell
        var cellData  :Wallet = wallets[indexPath.row]
        cell.walletName.text = cellData.login as String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        if State.currentServer != nil
        {
            State.currentWallet = wallets[indexPath.row]
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "manageState", userInfo: nil, repeats: true)
            apiManager.heartbeat(State.currentServer!)
        }
        else
        {
            State.toVC = SegueToServerVC
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToServerVC )
        }
    }
    
    final func logIn(notification: NSNotification)
    {
        state.append("logIN")
    }
    
    final func serverDenied(notification: NSNotification)
    {
        state.append("serverDenied")
    }
    
    final func manageState()
    {
        switch state.last!
        {
        case "logIN" :
            
            APIManager().timeSynchronize(State.currentServer!)
            
            timer.invalidate()
            for var index :Int = 0 ; index < state.count ; index++
            {
                if state[index] == "serverDenied"
                {
                    state.removeAtIndex(index)
                    index--
                }
            }
            State.toVC = SegueToMessages
            
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToDashboard )
            state.removeLast()
            
        case "serverDenied" :
            
            timer.invalidate()
            
            var alert :UIAlertView = UIAlertView(title: "Info", message: "Server is  unavailable. Try again later or check your server.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            state.removeLast()
            
        default :
            break
        }
    }
}
