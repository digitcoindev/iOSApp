import UIKit

class SettingsVC: AbstractViewController, UITableViewDataSource, UITableViewDelegate, APIManagerDelegate
{
    private enum SettingsCategory :Int {
        case General = 0
        case Security = 1
        case Server = 2
        case Notification = 3
    }
    
    let dataManager :CoreDataManager = CoreDataManager()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var _content :[[[String]]] = []
    private var _loadData :LoadData? = State.loadData
    private var _popUp :AbstractViewController? = nil
    private let _dataManager = CoreDataManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToSettings
        State.currentVC = SegueToSettings
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        
        _refreshData()
    }
    
    override func viewDidAppear(animated: Bool) {
        _refreshData()
    }
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToLoginVC)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return max(_content.count, 1)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if _content.count == 0 {return 1}
        return max(_content[section].count, 1)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if _content.count == 0 {
            return self.tableView!.dequeueReusableCellWithIdentifier("Loading")!
        }
        
        var cell :ProfileTableViewCell!

        if indexPath.row == 0 {
            cell = self.tableView!.dequeueReusableCellWithIdentifier("category cell") as! ProfileTableViewCell

        } else {
            cell = self.tableView!.dequeueReusableCellWithIdentifier("content cell") as! ProfileTableViewCell
        }
        
        
        cell.titleLabel!.text = _content[indexPath.section][indexPath.row][0]
        cell.contentLabel?.text = _content[indexPath.section][indexPath.row][1]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case SettingsCategory.General.rawValue :
            switch indexPath.row {
            case 1:
                _createPopUp("Chouse Language")
            case 2:
                if _dataManager.getWallets().count != 0 {
                    _createPopUp("ChousePrimAccount")
                }
                
            case 3:
                _createPopUp("InvoiceSettings")
                
            default:
                break
            }
        case SettingsCategory.Server.rawValue:
            switch indexPath.row {
            case 1:
                if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                    (self.delegate as! MainVCDelegate).pageSelected(SegueToServerVC)
                }
            default:
                break
            }
            
        default:
            break
        }
    }
    
    //MARK: - Private Methods
    
    private final func _refreshData(){
        _loadData = State.loadData
        titleLabel.text = "SETTINGS".localized("Configurations")
        var serverText = ""
        if let server = _loadData?.currentServer {
            serverText = server.address
        } else {
            serverText = "NONE".localized("None")
        }
        
        var accountText = ""
        if let account = _loadData?.currentWallet {
            accountText = account.login
        } else if _dataManager.getWallets().count == 0 {
            accountText = "NO_ACCOUNTS".localized("No Accounts")
        } else {
            accountText = "NONE".localized("None")
        }
        
        _content = []
        _content += [
            [
                ["GENERAL".localized("General")],
                ["LANGUAGE".localized("Language"), _loadData?.currentLanguage ?? "BASE".localized("Base")],
                ["ACCOUNT_PRIMATY".localized("Primary Account"), accountText],
                ["INVOICE".localized("Invoice"), "SET_CONFIGURATION".localized("Set configuration")]
            ],
            [
                ["SECURITY".localized("Security")],
                ["PASSWORD".localized("Password") ,"CHANGE".localized("Change")],
                ["TOUCH_ID".localized("Touch ID") ,"ON".localized("On")]
            ],
            [
                ["SERVER_SETTINGS".localized("Server Settings")],
                ["SERVER".localized("Server") ,serverText]
            ],
            [
                ["NOTIFICATION".localized("Notification")],
                ["UPDATE_INTERVAL".localized("Update Interval") ,"30 min"]
            ]
        ]
        
        tableView.reloadData()
    }
    
    private final func _createPopUp(withId: String) {
        if _popUp != nil {
            _popUp!.view.removeFromSuperview()
            _popUp!.removeFromParentViewController()
            _popUp = nil
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let popUpController :AbstractViewController =  storyboard.instantiateViewControllerWithIdentifier(withId) as! AbstractViewController
        popUpController.view.frame = CGRect(x: 0, y: topView.frame.height, width: popUpController.view.frame.width, height: popUpController.view.frame.height - topView.frame.height)
        popUpController.view.layer.opacity = 0
        popUpController.delegate = self
        
        _popUp = popUpController
        self.view.addSubview(popUpController.view)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            popUpController.view.layer.opacity = 1
            }, completion: nil)

    }
}
