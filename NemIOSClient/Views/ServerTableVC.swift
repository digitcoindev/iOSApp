import UIKit

class ServerTableVC: UITableViewController , UITableViewDataSource, UITableViewDelegate
{
    let dataManager : CoreDataManager = CoreDataManager()
    let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()

    var servers : NSArray = NSArray()
    var apiManager :APIManager = APIManager()
    
    var state :String = "none"
    var timer :NSTimer!
    
    var selectedCellIndex : Int = -1
    var observerServerConfirmed :AnyObject!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 10)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.layer.cornerRadius = 5

        observer.addObserver(self, selector: "serverConfirmed:", name: "heartbeatSuccessed", object: nil)
        observer.addObserver(self, selector: "serverDenied:", name: "heartbeatDenied", object: nil)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "manageState", userInfo: nil, repeats: true)

        servers = dataManager.getServers()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func manageState()
    {
        switch (self.state)
        {
        case "Confirmed" :
                State.currentServer = servers[selectedCellIndex] as? Server
                var loadData :LoadData = dataManager.getLoadData()
                
                loadData.currentServer = servers[selectedCellIndex] as Server
                dataManager.commit()
                
                APIManager().timeSynchronize(State.currentServer!)
                
                NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToLoginVC )
            
                timer.invalidate()

        case "Denied" :
            var alert :UIAlertView = UIAlertView(title: "Info", message: "Server is  unavailable.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        default :
            break
        }
        
        self.state = "none"
    }
    
    final func serverConfirmed(notification: NSNotification)
    {
        State.toVC = SegueToLoginVC
        
        self.state = "Confirmed"
        
    }

    
    final func serverDenied(notification: NSNotification)
    {
        self.state = "Denied"
    }
    
    override func didMoveToParentViewController(parent: UIViewController?)
    {
        if parent == nil
        {
            NSNotificationCenter.defaultCenter().removeObserver(self, name:"heartbeatSuccessed", object:nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name:"heartbeatDenied", object:nil)
        }
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"heartbeatSuccessed", object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"heartbeatDenied", object:nil)
    }
    // MARK: - Table view data source

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return servers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : ServerViewCell = self.tableView.dequeueReusableCellWithIdentifier("serverCell") as ServerViewCell
        var cellData  : Server = servers[indexPath.row] as Server
        
        cell.serverName.text = "  " + cellData.protocolType + "://" + cellData.address + ":" + cellData.port
        
        if servers[indexPath.row] as? Server == State.currentServer 
        {
            cell.indicatorON()
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if  State.currentServer != nil
        {
            (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: servers.indexOfObject(State.currentServer!), inSection: 0)) as ServerViewCell).disSelect()
        }
        
        var selectedServer :Server = servers[indexPath.row] as Server
        selectedCellIndex = indexPath.row
        
        apiManager.heartbeat(selectedServer)
        
        self.state = "heartbeat"
    }
}
