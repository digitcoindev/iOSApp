import UIKit

class MainMenuVC:  UITableViewController , UITableViewDataSource, UITableViewDelegate
{
    
    let dataManager : CoreDataManager = CoreDataManager()
    let deviceManager : plistFileManager = plistFileManager()
    
    var menuItems : NSMutableArray = NSMutableArray()
    var menu : NSArray = NSArray()
    override func viewDidLoad()
    {
        super.viewDidLoad()
                
        menu = deviceManager.getMenuItems()
        
        State.currentVC = SegueToMainMenu
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
                
        for item in menu
        {
            if(State.currentWallet != nil)
            {
                
                switch (item as String)
                {
                    
                case "Accounts", "Registration" :
                    break
                    
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
                switch (item as String)
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
        var cell : MainViewCell = self.tableView.dequeueReusableCellWithIdentifier("mainCell") as MainViewCell
        cell.title.text = menuItems.objectAtIndex(indexPath.row) as? String
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var page: String  = menuItems.objectAtIndex(indexPath.row) as String
        
       
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
            State.toVC = SegueToDashboard
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToDashboard )
            
        case "Map":
            State.toVC = SegueToGoogleMap
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToGoogleMap )
            
        default:
            print("")
            
        }
    }
}

