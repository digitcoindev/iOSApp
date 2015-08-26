import UIKit
@objc protocol AccountsChousePopUpDelegate {
    optional func didChouseAccount(account :AccountGetMetaData)
}
class AccountsChousePopUp: AbstractViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var _wallets :[AccountGetMetaData] = []
    private let _apiManager :APIManager = APIManager()

    var wallets :[AccountGetMetaData] {
        get {
            return _wallets
        }
        
        set {
            _wallets = newValue
            tableView.reloadData()
        }
    }
    
    //MARK: Load Methods

    override func viewDidLoad() {
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        _apiManager.delegate = self

    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    //MARK: UITableViewDataSource Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _wallets.count
    }
   
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell :WalletCell = tableView.dequeueReusableCellWithIdentifier("AccountsChousePopUpCell") as! WalletCell
        
        cell.walletName.text = _wallets[indexPath.row].address
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if self.delegate != nil && self.delegate!.respondsToSelector("didChouseAccount:") {
            (self.delegate as! AccountsChousePopUpDelegate).didChouseAccount!(_wallets[indexPath.row])
        }
        
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
}
