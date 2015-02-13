import UIKit

class ImportFromFile: UIViewController  , UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!

    let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()

    let fileManager : plistFileManager = plistFileManager()
    var importedAccounts :NSMutableArray!
    var index :Int = -1
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        observer.addObserver(self, selector: "validateData:", name: "Import", object: nil)
        
        importedAccounts = fileManager.getImportedAccounts()
        
        tableView.tableFooterView = UIView(frame: CGRectZero)

    }

    func validateData(notification: NSNotification)
    {
//        if fileManager.validatePair(importedAccounts.objectAtIndex(index) as String, password: notification.object as String)
//        {
//            var curIndex = index
//            index = -1
//            
//            importedAccounts.removeObjectAtIndex(curIndex)
//            tableView.deleteRowsAtIndexPaths(NSArray(object: NSIndexPath(forRow: curIndex, inSection: 0)), withRowAnimation: UITableViewRowAnimation.Left)
//        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return importedAccounts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if(indexPath.row == index)
        {
            var cell : ImportAccountCell = self.tableView.dequeueReusableCellWithIdentifier("open") as ImportAccountCell
            cell.accountName.text = importedAccounts[indexPath.row] as? String
            return cell
        }
        else
        {
            var cell : ImportAccountCell = self.tableView.dequeueReusableCellWithIdentifier("close") as ImportAccountCell
            cell.accountName.text = importedAccounts[indexPath.row] as? String
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if index == indexPath.row
        {
            
            return 86
        }
        else
        {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var curIndex = index
        index = indexPath.row
        
        
        if(curIndex >= 0)
        {
            tableView.reloadRowsAtIndexPaths(NSArray(object: NSIndexPath(forItem: curIndex, inSection: 0)), withRowAnimation: UITableViewRowAnimation.None)
        }
        
        tableView.reloadRowsAtIndexPaths(NSArray(object: indexPath), withRowAnimation: UITableViewRowAnimation.Automatic)
        
    }
}
