
import UIKit

class MainMenuVC:  UITableViewController , UITableViewDataSource, UITableViewDelegate
{
    
    let dataManager : CoreDataManager = CoreDataManager()
    let deviceManager : plistFileManager = plistFileManager()
    
    var state :[String] = ["none"]
    var timer :NSTimer!
    
    var menuItems : NSMutableArray = NSMutableArray()
    var menu : NSArray = NSArray()
    
    var walletData :AccountGetMetaData!
    var apiManager :APIManager = APIManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
                
        menu = deviceManager.getMenuItems()
        
        State.currentVC = SegueToMainMenu
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "manageState", userInfo: nil, repeats: true)

        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
                
        for item in menu
        {
            if(State.currentWallet != nil && State.currentServer != nil)
            {
                
                switch (item as! String)
                {
                    
                case "Registration" :
                    break
                    
                case "Profile" ,"Dashboard":
                    if State.fromVC == SegueToLoginVC
                    {
                        break
                    }
                    else
                    {
                        if State.fromVC != item as? String
                        {
                            menuItems.addObject(item)
                        }
                    }
                    
                default:
                    if State.fromVC != item as? String
                    {
                        menuItems.addObject(item)
                    }
                    break
                }
            }
            else
            {
                switch (item as! String)
                {
                case "Accounts" , "Servers" :
                    if State.fromVC != item as? String
                    {
                        menuItems.addObject(item)
                    }
                    break
                    
                default:
                    break
                    
                }
            }
        }
        
        var observer: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        observer.addObserver(self, selector: "accountGetSuccessed:", name: "accountGetSuccessed", object: nil)
        
        if State.currentServer != nil && State.currentWallet != nil
        {
            var address :String = AddressGenerator().generateAddressFromPrivateKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey))
            
            apiManager.accountGet(State.currentServer!, account_address: address)
        }
        else
        {
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToServerTable )
        }

    }
    
    final func manageState()
    {
        switch (state.last!)
        {
        case "Profile" :
            
            if walletData != nil
            {
                if walletData.cosignatories.count > 0
                {
                    State.toVC = SegueToProfileMultisig
                }
                else if walletData.cosignatoryOf.count > 0
                {
                    State.toVC = SegueToProfileCosignatoryOf
                }
                else
                {
                    State.toVC = SegueToProfile
                }
                
                state.removeLast()

                NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:State.toVC )
            }
            
        default :
            break
        }
    }
    
    final func accountGetSuccessed(notification: NSNotification)
    {
        walletData = (notification.object as! AccountGetMetaData)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return menuItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : MainViewCell = self.tableView.dequeueReusableCellWithIdentifier("mainCell") as! MainViewCell
        cell.title.text = menuItems.objectAtIndex(indexPath.row) as? String
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var page: String  = menuItems.objectAtIndex(indexPath.row) as! String
        
       
        switch (page)
        {
        case "Registration":
            State.toVC = SegueToRegistrationVC
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToRegistrationVC )
            
        case "Accounts":
            State.toVC = SegueToLoginVC
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToLoginVC )
            
        case "Servers":
            State.toVC = SegueToServerVC
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToServerVC )
            
        case "Dashboard":
            State.toVC = SegueToMessages
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToDashboard )
            
        case "Map":
            State.toVC = SegueToGoogleMap
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToGoogleMap )
            
        case "Profile":
            state.append("Profile")
            
        default:
            print("")
            
        }
    }
}

