import UIKit

class LoginVC: AbstractViewController, UITableViewDelegate, UITableViewDataSource, APIManagerDelegate, EditableTableViewCellDelegate, ChangeNamePopUptDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addWallet: UIButton!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
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
        
        navigationItem.title = "ACCOUNTS".localized()
        addWallet.setTitle("   " + "ADD_ACCOUNT".localized(), forState: UIControlState.Normal)
        editButton.title = "EDIT".localized()
        
        apiManager.delegate = self
        
        wallets  = dataManager.getWallets()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.layer.cornerRadius = 5
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        State.currentVC = SegueToLoginVC
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - IBAction
    
    @IBAction func addNewWallet(sender: AnyObject) {
        
        if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToAddAccountVC)
        }
    }
    
    @IBAction func settings(sender: AnyObject) {
        
        if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToSettings)
        }
    }
    
    @IBAction func editButtonTouchUpInside(sender: AnyObject) {
        if _popUp != nil { return }
        
        _isEditing = !_isEditing
        
        let title = _isEditing ? "DONE".localized() : "EDIT".localized()
        editButton.title = title
        
        self.tableView.setEditing(_isEditing, animated: false)
        
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
                
                if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
                    (self.delegate as! MainVCDelegate).pageSelected(SegueToServerVC)
                }
            }
        } else {
            selectedIndex = indexPath.row
            _createPopUp("ChangeNamePopUpProfile", name: wallets[indexPath.row].login)
        }
    }
    
    //MARK: - TableView Data Source

    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return _isEditing
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return _isEditing
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if sourceIndexPath.row == destinationIndexPath.row {
            return
        }
        
        let tempWallet = wallets[sourceIndexPath.row]
        
        wallets.removeAtIndex(sourceIndexPath.row)
        wallets.insert(tempWallet, atIndex: destinationIndexPath.row)
        
        for wallet in wallets {
            wallet.position = wallets.indexOf(wallet)! as NSNumber
        }
        
        dataManager.commit()
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
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: String(format: "DELETE_CONFIRMATION_MASSAGE_ACCOUNTS".localized(), (cell as! WalletCell).infoLabel.text!), preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            let index :NSIndexPath = self.tableView.indexPathForCell(cell)!
            
            if index.row < self.wallets.count {
                if let loadData = State.loadData {
                    if loadData.currentWallet == self.wallets[index.row] {
                        loadData.currentWallet = nil
                        self.dataManager.commit()
                    }
                }
                self.dataManager.deleteWallet(wallet: self.wallets[index.row])
                self.wallets.removeAtIndex(index.row)
                
                self.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Left)
            }
            
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - APIManagerDelegate Methods
    
    final func heartbeatResponceFromServer(server :Server ,successed :Bool) {
        if successed {
            APIManager().timeSynchronize(server)
            
            State.toVC = SegueToMessages
            
            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
                (self.delegate as! MainVCDelegate).pageSelected(SegueToDashboard)
            }
        } else {
            
            State.currentServer = nil
            State.toVC = SegueToServerVC
            
            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
                (self.delegate as! MainVCDelegate).pageSelected(SegueToServerVC)
            }
        }
    }
}
