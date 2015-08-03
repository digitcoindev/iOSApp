
import UIKit

class MainMenuVC:  UITableViewController , UITableViewDataSource, UITableViewDelegate
{
    let dataManager : CoreDataManager = CoreDataManager()
    let deviceManager : plistFileManager = plistFileManager()
    
    var delegate :AnyObject?
    
    var state :[String] = ["none"]
    var timer :NSTimer!
    
    var menuItems : NSMutableArray = NSMutableArray()
    var menu : NSArray = NSArray()
    
    var walletData :AccountGetMetaData!
    var apiManager :APIManager = APIManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        State.currentVC = SegueToMainMenu

        menu = deviceManager.getMenuItems()
        menu = [SegueToRegistrationVC, SegueToLoginVC, SegueToServerVC, SegueToMessages, SegueToGoogleMap , SegueToProfile, SegueToExportAccount]
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
                    
                case SegueToRegistrationVC :
                    break
                    
                case SegueToProfile ,SegueToDashboard, SegueToExportAccount , SegueToMessages, SegueToGoogleMap :
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
                case SegueToLoginVC , SegueToServerVC :
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

    }
    
    final func manageState()
    {
        switch (state.last!)
        {
        case SegueToProfile :
            
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
            
        case SegueToDashboard:
            State.toVC = SegueToMessages
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToDashboard )
            
        case SegueToProfile:
            state.append(SegueToProfile)
            
        default:
            State.toVC = page
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:page )
            
        }
    }
}

