
import UIKit

class MainMenuVC:  AbstractViewController, APIManagerDelegate
{
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!

    var menuItems : NSMutableArray = NSMutableArray()
    var menu : NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToMainMenu
        State.currentVC = SegueToMainMenu
        
        titleLabel.text = "MORE".localized()
        
        menu = [SegueToLoginVC, SegueToGoogleMap, SegueTomultisigAccountManager, SegueToHarvestDetails, SegueToExportAccount]
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
                
        for page in menu {
            switch page {
            default :
                menuItems.addObject(page)
            }
        }
    }

    // MARK: - @IBAction

    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(State.lastVC)
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : MainViewCell = self.tableView.dequeueReusableCellWithIdentifier("mainCell") as! MainViewCell
        var titleText = menuItems.objectAtIndex(indexPath.row) as? String
        switch titleText!
        {
        case SegueToLoginVC:
            titleText = "SWITCH_ACCOUNT".localized()
        case SegueToExportAccount:
            titleText = "EXPORT_ACCOUNT".localized()
        case SegueToGoogleMap:
            titleText = "MAP".localized()
        case SegueToHarvestDetails:
            titleText = "HARVEST_DETAILS".localized()
        case SegueTomultisigAccountManager:
            titleText = "MULTISIG".localized()
        default:
            break
        }
        cell.title.text = titleText
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var page: String  = menuItems.objectAtIndex(indexPath.row) as! String
        
        State.toVC = page
        
        switch page
        {
        case SegueToExportAccount:
            State.nextVC = page
            page = SegueToPasswordExport
        default:
            break
        }
        
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(page)
        }
    }
}

