import UIKit

class LoginVC: AbstractViewController, UITableViewDelegate, APIManagerDelegate, EditableTableViewCellDelegate, ChangeNamePopUptDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addWallet: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    //MARK: - Variables
    
    let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()
    
    var dataManager :CoreDataManager = CoreDataManager()
    var apiManager :APIManager = APIManager()
    
    var wallets :[Wallet] = [Wallet]()
    var selectedIndex :Int  = -1
    
    private var _popUp :AbstractViewController? = nil
    private var _isEditing = false
    
    //MARK: - Load Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        State.cleanVCs()
        State.currentVC = SegueToLoginVC
        
        titleLabel.text = "ACCOUNTS".localized()
        addWallet.setTitle("   " + "ADD_ACCOUNT".localized(), forState: UIControlState.Normal)
        editButton.setTitle("EDIT".localized(), forState: UIControlState.Normal)
        
        apiManager.delegate = self
        
        wallets  = dataManager.getWallets().reverse()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.layer.cornerRadius = 5



    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - IBAction
    
    @IBAction func addNewWallet(sender: AnyObject) {
        
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToAddAccountVC)
        }
    }
    
    @IBAction func settings(sender: AnyObject) {
        
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToSettings)
        }
    }
    
    @IBAction func editButtonTouchUpInside(sender: AnyObject) {
//        let things = ["Things to share"]
//        
//        let activityViewController = UIActivityViewController(activityItems: things, applicationActivities: nil)
//        self.presentViewController(activityViewController, animated: true, completion: nil)
        if _popUp != nil { return }
        
        _isEditing = !_isEditing

        for cell in self.tableView.visibleCells {
            (cell as! WalletCell).isEditable = _isEditing
        }
    }
    
    //MARK: - TableView Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : WalletCell = self.tableView.dequeueReusableCellWithIdentifier("walletCell") as! WalletCell
        cell.isEditable = _isEditing
        cell.editDelegate = self
        let cellData  :Wallet = wallets[indexPath.row]
        
        cell.infoLabel.attributedText = NSMutableAttributedString(string: cellData.login as String , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 16)!])
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !_isEditing {
            if State.currentServer != nil {
                State.currentWallet = wallets[indexPath.row]
                apiManager.heartbeat(State.currentServer!)
            }
            else {
                State.toVC = SegueToServerVC
                
                if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                    (self.delegate as! MainVCDelegate).pageSelected(SegueToServerVC)
                }
            }
        } else {
            selectedIndex = indexPath.row
            _createPopUp("ChangeNamePopUpProfile", name: wallets[indexPath.row].login)
        }
    }
    
    //MARK: - Private Methods
    
    private final func _createPopUp(withId: String , name: String? = nil) {
         popUpClosed()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let popUpController :AbstractViewController =  storyboard.instantiateViewControllerWithIdentifier(withId) as! AbstractViewController
        popUpController.view.frame = CGRect(x: 0, y: 40, width: popUpController.view.frame.width, height: popUpController.view.frame.height - 40)
        popUpController.view.layer.opacity = 0
        popUpController.delegate = self
        
        if withId == "ChangeNamePopUpProfile"{
            (popUpController as! ChangeNamePopUp).newName.text = name
        }
        
        _popUp = popUpController
        self.view.addSubview(popUpController.view)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            popUpController.view.layer.opacity = 1
            }, completion: nil)
        
    }
    
    //MARK: - ChangeNamePopUpDelegate Methods
    
    func nameChanged(name :String) {
        wallets[selectedIndex].login = name
        dataManager.commit()
        tableView.reloadData()
    }
    
    func popUpClosed(){
        if _popUp != nil {
            _popUp!.view.removeFromSuperview()
            _popUp!.removeFromParentViewController()
            _popUp = nil
        }
    }

    //MARK: - EditableTableViewCellDelegate Delegate
    
    func deleteCell(cell: EditableTableViewCell){
        let index :NSIndexPath = tableView.indexPathForCell(cell)!
        
        if index.row < wallets.count {
            if let loadData = State.loadData {
                if loadData.currentWallet == wallets[index.row] {
                    loadData.currentWallet = nil
                    dataManager.commit()
                }
            }
            dataManager.deleteWallet(wallet: wallets[index.row])
            wallets.removeAtIndex(index.row)
            
            tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Left)
        }
    }
    
    //MARK: - APIManagerDelegate Methods
    
    final func heartbeatResponceFromServer(server :Server ,successed :Bool) {
        if successed {
            APIManager().timeSynchronize(server)
            
            State.toVC = SegueToMessages
            
            if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                (self.delegate as! MainVCDelegate).pageSelected(SegueToDashboard)
            }
        } else {
            
            State.currentServer = nil
            State.toVC = SegueToServerVC
            
            if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                (self.delegate as! MainVCDelegate).pageSelected(SegueToServerVC)
            }
        }
    }
}
