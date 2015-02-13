import UIKit

class ServerTableVC: UITableViewController , UITableViewDataSource, UITableViewDelegate
{

    let dataManager : CoreDataManager = CoreDataManager()
    var servers : NSArray = NSArray()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 10)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.layer.cornerRadius = 5

        servers = dataManager.getServers()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
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
        
        State.currentServer = servers[indexPath.row] as? Server
        var loadData :LoadData = dataManager.getLoadData()
        
        loadData.currentServer = servers[indexPath.row] as Server
        dataManager.commit()
        
        (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: servers.indexOfObject(State.currentServer!), inSection: 0)) as ServerViewCell).indicatorON()
        
        State.toVC = SegueToLoginVC
        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToLoginVC )
    }
}
