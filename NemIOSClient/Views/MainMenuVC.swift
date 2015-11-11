
import UIKit

class MainMenuVC:  AbstractViewController, APIManagerDelegate
{
    @IBOutlet var tableView: UITableView!

    var menuItems : NSMutableArray = NSMutableArray()
    var menu : NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToMainMenu
        State.currentVC = SegueToMainMenu
        
        menu = [SegueToLoginVC, SegueToServerVC, SegueToGoogleMap , SegueToProfile, SegueToHarvestDetails, SegueToExportAccount]
        
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
        case SegueToHarvestDetails:
            titleText = "Harvest Details"
        default:
            break
        }
        cell.title.text = titleText
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let page: String  = menuItems.objectAtIndex(indexPath.row) as! String
        
        State.toVC = page
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(page)
        }
    }
}

