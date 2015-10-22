import UIKit

class MultisigAccountManager: AbstractViewController, UITableViewDelegate, APIManagerDelegate
{

    @IBOutlet weak var chouseButton: ChouseButton!
    @IBOutlet weak var tableView: UITableView!
    
    var walletData :AccountGetMetaData!
    var timer :NSTimer!
    var state :[String] = ["none"]

    var currentCosignatories :[String] = [String]()
    var removeArray :[AccountGetMetaData]!
    var addArray = [String]()
    
    private var _mainAccount :AccountGetMetaData? = nil
    private var _activeAccount :AccountGetMetaData? = nil
    
    private let _apiManager :APIManager =  APIManager()
    
    private var _popUps :[AbstractViewController] = []
    
    private var _currentCosignatories :[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        State.fromVC = SegueTomultisigAccountManager
        State.currentVC = SegueTomultisigAccountManager
        
        _apiManager.delegate = self
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey)
        
        _apiManager.accountGet(State.currentServer!, account_address: account_address)
    }
    
    final func manageState() {
        switch (state.last!) {
            
        case "prepareAnnounceSuccessed" :
            state.removeLast()
            let alert1 :UIAlertController = UIAlertController(title: NSLocalizedString("INFO", comment: "Title"), message: "Changes are confirmed and await \nfor server validation", preferredStyle: UIAlertControllerStyle.Alert)
            
            let ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive) {
                    alertAction -> Void in
            }
            
            alert1.addAction(ok)
            self.presentViewController(alert1, animated: true, completion: nil)
            
        case "prepareAnnounceDenied" :
            state.removeLast()
            let alert1 :UIAlertController = UIAlertController(title: NSLocalizedString("INFO", comment: "Title"), message: "Changes are not confirmed,\nplease try again later.", preferredStyle: UIAlertControllerStyle.Alert)
            
            let ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive) {
                    alertAction -> Void in
            }
            
            alert1.addAction(ok)
            self.presentViewController(alert1, animated: true, completion: nil)
            
        default :
            break
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentCosignatories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell :KeyCell = self.tableView.dequeueReusableCellWithIdentifier("KeyCell") as! KeyCell
        
        cell.key.text = ""
        cell.cellIndex = indexPath.row
        
        cell.key.text = cell.key.text! + currentCosignatories[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    final func deleteCellAtIndex(notification: NSNotification) {
        let index = notification.object as! Int
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        
        currentCosignatories.removeAtIndex(index)
        self.tableView.deleteRowsAtIndexPaths([indexPath] , withRowAnimation: .Fade)
    }
    
    @IBAction func addChanges(sender: AnyObject) {
        let newPublicKey :String = (sender as! UITextField).text!
        if newPublicKey.utf16.count == 64 {
            var find : Bool = false
            for publicKey in currentCosignatories {
                if publicKey == newPublicKey {
                    find = true
                    break
                }
            }
            
            if !find {
                currentCosignatories.append(newPublicKey)
                tableView.reloadData()
            }
        }
    }

    
    @IBAction func saveChanges(sender: AnyObject) {
        removeArray = walletData.cosignatories
        
        for publicKey in currentCosignatories {
            var find = false
            for var index = 0 ; index < removeArray.count ;index++ {
                if publicKey == removeArray[index].publicKey as String {
                    find = true
                    removeArray.removeAtIndex(index)
                }
            }
            
            if !find {
                addArray.append(publicKey)
            }
        }
        
        if removeArray.count > 1 {
            let alert :UIAlertController = UIAlertController(title: NSLocalizedString("INFO", comment: "Title"), message: "Yikes. You can remove only one cosignatori per transaction.", preferredStyle: UIAlertControllerStyle.Alert)
            
            let ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive) {
                    alertAction -> Void in
                    
                    self.currentCosignatories.removeAll(keepCapacity: false)
                    
                    for cosignatory in self.walletData.cosignatories
                    {
                        self.currentCosignatories.append(cosignatory.publicKey as String)
                    }
                    
                    self.tableView.reloadData()
            }
            
            alert.addAction(ok)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if (addArray.count - removeArray.count + walletData.cosignatories.count) > 16 {
            let alert :UIAlertController = UIAlertController(title: NSLocalizedString("INFO", comment: "Title"), message: "Yikes. Too many cosignatories.", preferredStyle: UIAlertControllerStyle.Alert)
            
            let ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive) {
                    alertAction -> Void in
                    
                    self.currentCosignatories.removeAll(keepCapacity: false)
                    
                    for cosignatory in self.walletData.cosignatories
                    {
                        self.currentCosignatories.append(cosignatory.publicKey as String)
                    }
                    
                    self.tableView.reloadData()
            }
            
            alert.addAction(ok)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            let fee = 10 + 6 * Int64(addArray.count + removeArray.count)
            
            let alert1 :UIAlertController = UIAlertController(title: "Confirmation", message: "Are you agree with changes? It will cost \(fee) XEM", preferredStyle: UIAlertControllerStyle.Alert)
            
            let confirm :UIAlertAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default) {
                    alertAction -> Void in
                    
                    let transaction :AggregateModificationTransaction = AggregateModificationTransaction()
                    let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
                    let publickey = self.walletData.publicKey
                    
                    transaction.timeStamp = TimeSynchronizator.nemTime
                    transaction.deadline = TimeSynchronizator.nemTime + waitTime
                    transaction.version = 1
                    transaction.signer = publickey
                    transaction.privateKey = privateKey
                    transaction.minCosignatory = self.walletData.cosignatories.count - self.removeArray.count + self.addArray.count
                    
                    for cosignatori in self.removeArray
                    {
                        transaction.addModification(2, publicKey: cosignatori.publicKey as String)
                    }
                    
                    for publickey in self.addArray
                    {
                        transaction.addModification(1, publicKey: publickey)
                    }
                    
                    transaction.fee = 10 + 6 * Double(self.addArray.count + self.removeArray.count)
                    
                    APIManager().prepareAnnounce(State.currentServer!, transaction: transaction)
                    
                    self.currentCosignatories.removeAll(keepCapacity: false)
                    
                    for cosignatory in self.walletData.cosignatories
                    {
                        self.currentCosignatories.append(cosignatory.publicKey as String)
                    }
                    
                    self.addArray.removeAll(keepCapacity: false)
                    self.removeArray.removeAll(keepCapacity: false)
                    
                    self.tableView.reloadData()
                    
            }
            
            
            let cancel :UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive) {
                    alertAction -> Void in
                    
                    self.currentCosignatories.removeAll(keepCapacity: false)
                    
                    for cosignatory in self.walletData.cosignatories
                    {
                        self.currentCosignatories.append(cosignatory.publicKey as String)
                    }
                    
                    self.addArray.removeAll(keepCapacity: false)
                    self.removeArray.removeAll(keepCapacity: false)
                    
                    self.tableView.reloadData()
            }
            
            alert1.addAction(cancel)
            alert1.addAction(confirm)
            
            self.presentViewController(alert1, animated: true, completion: nil)
        }
    }
    
    @IBAction func chouseAccount(sender: AnyObject) {
        if _popUps.count == 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let accounts :AccountsChousePopUp =  storyboard.instantiateViewControllerWithIdentifier("AccountsChousePopUp") as! AccountsChousePopUp
            
            accounts.view.frame = tableView.frame
            
            accounts.view.layer.opacity = 0
            accounts.delegate = self
            
            var wallets = _mainAccount?.cosignatoryOf ?? []
            
            if _mainAccount != nil
            {
                wallets.append(self._mainAccount!)
            }
            accounts.wallets = wallets
            
            if accounts.wallets.count > 0
            {
                _popUps.append(accounts)
                self.view.addSubview(accounts.view)
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    accounts.view.layer.opacity = 1
                    }, completion: nil)
            }
        } else {
            _popUps.first?.view.removeFromSuperview()
            _popUps.removeFirst()
        }
    }
    
    private func _generateTableData() {
    
    }
    
    //MARK: - AccountChousePopUp Methods
    
    func didChouseAccount(account: AccountGetMetaData) {
        
        if _popUps.count > 0 {
            _popUps.first?.view.removeFromSuperview()
            _popUps.removeFirst()
        }
        _activeAccount = nil
        _apiManager.accountGet(State.currentServer!, account_address: account.address)
    }

    //MARK: - APIManagerDelegate Methods
    
    func accountGetResponceWithAccount(account: AccountGetMetaData?) {
        
        if account != nil {
            
            chouseButton.setTitle(account?.address, forState: UIControlState.Normal)
            
            if _mainAccount == nil {
                _mainAccount = account
            }
            
            if _activeAccount == nil {
                _activeAccount = account
                _generateTableData()
            }
        }
    }
}