
import UIKit

class MainMenuVC:  AbstractViewController, APIManagerDelegate
{
    @IBOutlet var tableView: UITableView!

    var menuItems : NSMutableArray = NSMutableArray()
    var menu : NSArray = NSArray()
    
    private var _walletData :AccountGetMetaData!
    private let _apiManager :APIManager = APIManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.currentVC = SegueToMainMenu
        _apiManager.delegate = self
        
        menu = [SegueToRegistrationVC, SegueToLoginVC, SegueToServerVC, SegueToMessages, SegueToGoogleMap , SegueToProfile, SegueToExportAccount]
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
                
        for item in menu {
            if(State.currentWallet != nil && State.currentServer != nil) {
                
                switch (item as! String) {
                    
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
            else {
                switch (item as! String) {
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
        
        
        if State.currentServer != nil && State.currentWallet != nil {
            let address :String = AddressGenerator.generateAddressFromPrivateKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey))
            
            _apiManager.accountGet(State.currentServer!, account_address: address)
        }
    }
    
    func accountGetResponceWithAccount(account: AccountGetMetaData?) {
        _walletData = account
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : MainViewCell = self.tableView.dequeueReusableCellWithIdentifier("mainCell") as! MainViewCell
        cell.title.text = menuItems.objectAtIndex(indexPath.row) as? String
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let page: String  = menuItems.objectAtIndex(indexPath.row) as! String
        
       
        switch (page) {
            
        case SegueToProfile:
            if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                if _walletData != nil  {
                    if _walletData.cosignatories.count > 0 {
                        State.toVC = SegueToProfileMultisig
                    }
                    else if _walletData.cosignatoryOf.count > 0 {
                        State.toVC = SegueToProfileCosignatoryOf
                    }
                    else {
                        State.toVC = SegueToProfile
                    }
                    
                    (self.delegate as! MainVCDelegate).pageSelected(State.toVC)
                }            }
        default:
            State.toVC = page
            if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                (self.delegate as! MainVCDelegate).pageSelected(page)
            }
        }
    }
}

