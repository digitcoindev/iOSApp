import UIKit

class ServerTableVC: UITableViewController , UITableViewDataSource, UITableViewDelegate
{

    let dataManager : CoreDataManager = CoreDataManager()
    var servers : NSArray = NSArray()
    var apiManager :APIManager = APIManager()
    let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()
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
        
        servers = dataManager.getServers()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    final func serverConfirmed(notification: NSNotification)
    {
        
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        let mainQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
        
        dispatch_async(backgroundQueue,
            {
            self.serverConfirmedStepTwo()
        })
        dispatch_async(mainQueue,
            {
                State.toVC = SegueToLoginVC
                
                NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToLoginVC )
        })
    }
    
    final func serverConfirmedStepTwo()
    {
        State.currentServer = servers[selectedCellIndex] as? Server
        var loadData :LoadData = dataManager.getLoadData()
        
        loadData.currentServer = servers[selectedCellIndex] as Server
        dataManager.commit()
    }
    
    final func serverDenied(notification: NSNotification)
    {
        //for test
        State.currentServer = servers[selectedCellIndex] as? Server
        var loadData :LoadData = dataManager.getLoadData()
        
        loadData.currentServer = servers[selectedCellIndex] as Server
        dataManager.commit()
        
        (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: servers.indexOfObject(State.currentServer!), inSection: 0)) as ServerViewCell).indicatorON()
        
        State.toVC = SegueToLoginVC
        
        var alert :UIAlertView = UIAlertView(title: "Info", message: "Server is  unavailable.", delegate: self, cancelButtonTitle: "OK")
        alert.show()
        
        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToLoginVC )
        //for test
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"serverConfirmed", object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"serverDenied", object:nil)
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
        
    }
}
