
import UIKit

class MoreMenuViewController:  AbstractViewController, APIManagerDelegate
{
    @IBOutlet var tableView: UITableView!

//    var menuItems : NSMutableArray = NSMutableArray()
    var menu : NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        State.fromVC = SegueToMainMenu
        
        // TODO: Hidden in Version 2 Build 26 https://github.com/NewEconomyMovement/NEMiOSApp/issues/147
        
//        menu = [SegueTomultisigAccountManager, SegueToHarvestDetails, SegueToExportAccount]
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
                
//        for page in menu {
//            switch page {
//            default :
//                menuItems.addObject(page)
//            }
//        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        tabBarController?.title = "MORE".localized()
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
//        State.currentVC = SegueToMainMenu
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return menuItems.count
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : MainViewCell = self.tableView.dequeueReusableCellWithIdentifier("mainCell") as! MainViewCell
//        var titleText = menuItems.objectAtIndex(indexPath.row) as? String
//        switch titleText!
//        {
//        case SegueToExportAccount:
//            titleText = "EXPORT_ACCOUNT".localized()
//        case SegueToHarvestDetails:
//            titleText = "HARVEST_DETAILS".localized()
//        case SegueTomultisigAccountManager:
//            titleText = "MULTISIG".localized()
//        default:
//            break
//        }
//        cell.title.text = titleText
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        var page: String  = menuItems.objectAtIndex(indexPath.row) as! String
//
//        State.toVC = page
//        
//        switch page
//        {
//        case SegueToExportAccount:
//            State.nextVC = page
//            page = SegueToPasswordExport
//        default:
//            break
//        }
//        
//        if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
//            (self.delegate as! MainVCDelegate).pageSelected(page)
//        }
        
//        switch page
//        {
//        case SegueToExportAccount:
//            performSegueWithIdentifier("showAccountExportPasswordViewController", sender: nil)
//            
//        case SegueToHarvestDetails:
//            performSegueWithIdentifier("showHarvestingViewController", sender: nil)
//            
//        case SegueTomultisigAccountManager:
//            performSegueWithIdentifier("showMultisignatureViewController", sender: nil)
//            
//        default:
//            break
//        }
    }
}

