//
//  TransactionOverviewViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import Contacts

class TransactionOverviewViewController: UIViewController , UITableViewDelegate ,UISearchBarDelegate, APIManagerDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userInfo: UILabel!
    
    let dataManager : CoreDataManager = CoreDataManager()
    var walletData :AccountGetMetaData?
    
    private var _apiManager :APIManager = APIManager()
    private var _correspondents :[Correspondent] = []
    
    private var _displayList :NSArray = NSArray()
    private var _searchText :String = ""
    
    private var _requestsLimit: Int = 2
    private var _transactionsLimit: Int = 50
    private var _showUnconfirmed = true
    
    private var _requestCounter = 0
    private var _timer: NSTimer? = nil
    
    private var _account_address: String? = nil
    private var _transactions:[TransferTransaction] = []
    
    // TODO: Hidden in Version 2 Build 18 https://github.com/NewEconomyMovement/NEMiOSApp/issues/107
    //    private var _searchBar : UISearchBar!
    
    // MARK: - Load Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        State.fromVC = SegueToMessages
        State.currentContact = nil
        
        userInfo.text = "NO_INTERNET_CONNECTION".localized()
        //customMessageButton.setTitle("NEW".localized(), forState: UIControlState.Normal)
        tableView.layer.cornerRadius = 2
        _apiManager.delegate = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // TODO: Hidden in Version 2 Build 18 https://github.com/NewEconomyMovement/NEMiOSApp/issues/107
        //        _searchBar = UISearchBar(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.size.width, height: 44)))
        //        _searchBar.delegate = self
        //        tableView.tableHeaderView = _searchBar
        //        _searchBar.showsCancelButton = false
        //        tableView.setContentOffset(CGPoint(x: 0, y: _searchBar.frame.height), animated: false)
        
        _displayList = _correspondents
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
        let publicKey = KeyGenerator.generatePublicKey(privateKey!)
        _account_address = AddressGenerator.generateAddress(publicKey)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.refreshTransactionList()
            if AddressBookManager.isAllowed ?? false {
                self.findCorrespondentName()
            }
        })
        
        if State.currentContact != nil {
            
            performSegueWithIdentifier("showTransactionNormalMessagesViewController", sender: nil)
        }
        
        if let server = State.currentServer {
            _apiManager.timeSynchronize(server)
        }
        
        self.tableView.allowsMultipleSelectionDuringEditing = false
        
        _timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(updateInterval), target: self, selector: #selector(TransactionOverviewViewController.refreshTransactionList), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        tabBarController?.title = "MESSAGES".localized()
        
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(segueToTransactionSendViewController))
//        let rightBarButton = UIButton()
//        let barButtonImage = UIImage(named: "note")
//        rightBarButton.setImage(barButtonImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        rightBarButton.tintColor = UIColor.whiteColor()
//        rightBarButton.frame = CGRectMake(0, 0, 30, 30)
        
//        rightBarButton.addTarget(self, action: #selector(segueToTransactionSendViewController), forControlEvents: .TouchUpInside)
        
//        let rightNavigationBarButton = UIBarButtonItem()
//        rightNavigationBarButton.customView = rightBarButton
        
        tabBarController?.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        State.currentVC = SegueToMessages
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        _timer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - APIManagerDelegate Methods
    
    final func accountGetResponceWithAccount(account: AccountGetMetaData?) {
        if let responceAccount = account {
            walletData = responceAccount
            
            if walletData!.cosignatories.count > 0 {
                tabBarController?.navigationItem.rightBarButtonItem!.enabled = false
            }
            
            var userDescription :NSMutableAttributedString!
            
            if let wallet = State.currentWallet {
                userDescription = NSMutableAttributedString(string: "\(wallet.login)")
            }
            
            let attribute = [NSForegroundColorAttributeName : UIColor(red: 65/256, green: 206/256, blue: 123/256, alpha: 1)]
            let balance = " \((walletData!.balance / 1000000).format()) XEM"
            
            userDescription.appendAttributedString(NSMutableAttributedString(string: balance, attributes: attribute))
            
            self.userInfo.attributedText = userDescription
        } else {
            self.userInfo.attributedText = NSMutableAttributedString(string: "LOST_CONNECTION".localized(), attributes: [NSForegroundColorAttributeName : UIColor.redColor()])
        }
    }
    
    final func accountTransfersAllResponceWithTransactions(data: [TransactionPostMetaData]?) {
        if let data = data {
            _requestCounter += 1
            
            if _requestCounter == 1 {
                State.currentWallet?.lastTransactionHash = data.first?.hashString
                CoreDataManager().commit()
            }
            
            let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
            let publicKey = KeyGenerator.generatePublicKey(privateKey!)
            
            for inData in data {
                var innerTransaction :TransferTransaction? = nil
                
                switch (inData.type) {
                case transferTransaction :
                    innerTransaction = inData as? TransferTransaction
                    
                case multisigTransaction:
                    
                    let multisigT  = inData as! MultisigTransaction
                    
                    switch(multisigT.innerTransaction.type) {
                    case transferTransaction :
                        innerTransaction = multisigT.innerTransaction as? TransferTransaction
                        
                    default:
                        break
                    }
                default:
                    break
                }
                
                if innerTransaction == nil {
                    continue
                }
                
                if innerTransaction!.signer != publicKey && innerTransaction!.recipient != self._account_address {
                    continue
                }
                
                _transactions.append(innerTransaction!)
            }
            
            if data.count >= 25 && _requestCounter < _requestsLimit && _transactions.count <= _transactionsLimit{
                _apiManager.accountTransfersAll(State.currentServer!, account_address: _account_address!, aditional: "&id=\(Int(data.last!.id))")
            } else {
                guard let server = State.currentServer else { return }
                guard let address = walletData?.address else { return }
                
                _apiManager.unconfirmedTransactions(server, account_address: address)
            }
            
        } else {
            self.userInfo.attributedText = NSMutableAttributedString(string: "LOST_CONNECTION".localized(), attributes: [NSForegroundColorAttributeName : UIColor.redColor()])
        }
    }
    
    final func unconfirmedTransactionsResponceWithTransactions(data: [TransactionPostMetaData]?) {
        if let data = data {
            
            var needToSign = false

            if data.count > 0 {
                let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
                let publicKey = KeyGenerator.generatePublicKey(privateKey!)
                
                var addTransactions :[TransferTransaction] = []
                var transaction :TransferTransaction? = nil

                for inTransaction in data {
                    
                    switch inTransaction.type {
                    case multisigTransaction:
                        var findSignature = false

                        let innerTransaction:TransactionPostMetaData = (inTransaction as! MultisigTransaction).innerTransaction

                        switch innerTransaction.type {
                        case transferTransaction:
                            if (innerTransaction as! TransferTransaction).recipient == walletData?.address {
                                findSignature = true
                            }
                            transaction = innerTransaction as? TransferTransaction
                        default:
                            findSignature = true
                            break
                        }
                        
                        if (inTransaction as! MultisigTransaction).signer == walletData!.publicKey || innerTransaction.signer == walletData!.publicKey {
                            findSignature = true
                        }
                        
                        for sign in (inTransaction as! MultisigTransaction).signatures {
                            if walletData!.publicKey == sign.signer {
                                findSignature = true
                            }
                        }
                        
                        if !findSignature {
                            needToSign = true
                        }
                        
                    case transferTransaction:
                        transaction = inTransaction as? TransferTransaction
                        
                    default :
                        break
                    }
                    
                    if transaction == nil {
                        continue
                    }
                    
                    if transaction!.signer != publicKey && transaction!.recipient != self._account_address {
                        continue
                    }
                    
                    addTransactions.append(transaction!)

                }
                
                _transactions = addTransactions + _transactions
            }
            
            _correspondents = Correspondent.generateCorespondetsFromTransactions(_transactions)
            _displayList = _correspondents
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                
                if needToSign && self._showUnconfirmed {
                    let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: "UNCONFIRMED_TRANSACTIONS_DETECTED".localized(), preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let ok :UIAlertAction = UIAlertAction(title: "SHOW_TRANSACTIONS".localized(), style: UIAlertActionStyle.Default) {
                        alertAction -> Void in
                        
                        self.performSegueWithIdentifier("showTransactionUnconfirmedViewController", sender: nil)
                    }
                    
                    let cancel :UIAlertAction = UIAlertAction(title: "REMIND_LATER".localized(), style: UIAlertActionStyle.Default) {
                        alertAction -> Void in
                        self._showUnconfirmed = false
                    }
                    
                    alert.addAction(cancel)
                    alert.addAction(ok)
       
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    // MARK: - Help Methods
    
    final func sort_correspondents(_correspondents :[Correspondent])->[Correspondent] {
        var _correspondentsIn = _correspondents
        var data :[CorrespondentCellData] = [CorrespondentCellData]()
        
        for correspondent in _correspondentsIn {
            var value = CorrespondentCellData()
            value.correspondent = correspondent
            value.lastMessage = correspondent.transaction
            data.append(value)
        }
        
        for var index = 0 ; index < data.count ; index += 1 {
            var sorted = true
            
            for var indexIN = 0 ; indexIN < data.count - 1 ; indexIN += 1 {
                var firstValue :Int!
                if data[indexIN].lastMessage != nil {
                    firstValue = Int(data[indexIN].lastMessage!.id)
                }
                else {
                    firstValue = -1
                }
                
                var secondValue :Int!
                if data[indexIN + 1].lastMessage != nil {
                    secondValue = Int(data[indexIN + 1].lastMessage!.id)
                }
                else {
                    secondValue = -1
                }
                
                if firstValue < secondValue || (secondValue == -1 &&  secondValue != firstValue) {
                    let accum = data[indexIN + 1]
                    data[indexIN + 1] = data[indexIN]
                    data[indexIN] = accum
                    
                    sorted = false
                }
            }
            
            if sorted {
                break
            }
        }
        
        _correspondentsIn.removeAll(keepCapacity: false)
        
        for correspondent in data {
            _correspondentsIn.append(correspondent.correspondent)
        }
        
        return _correspondentsIn
    }
    
    final func findCorrespondentName() {
        let contacts :NSArray = AddressBookManager.contacts
        
        for correspondent in _correspondents {
            if correspondent.name.utf16.count > 20 {
                var find = false
                for contact in contacts {
                    let emails: [CNLabeledValue] = contact.emailAddresses
                    
                    for email in emails {
                        if email.label == "NEM" && email.value as! String == correspondent.address {
                            correspondent.name = (contact.givenName ?? "") + " " + (contact.familyName ?? "")
                            find = true
                            break
                        }
                    }
                    
                    if find {
                        break
                    }
                }
            }
        }
    }
    
    final func refreshTransactionList() {
        if State.currentServer != nil && _account_address != nil {
            _transactions = []
            _requestCounter = 0
            
            _apiManager.accountGet(State.currentServer!, account_address: _account_address!)
            _apiManager.accountTransfersAll(State.currentServer!, account_address: _account_address!)
        }
        else {
            
            performSegueWithIdentifier("showSettingsServerViewController", sender: nil)
        }
    }
    
    // TODO: Hidden in Version 2 Build 18 https://github.com/NewEconomyMovement/NEMiOSApp/issues/107
    // MARK: - Search Bar Data Source
    
    //    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    //        tableView.setContentOffset(CGPoint(x: 0, y: 44), animated: true)
    //
    //        _displayList = _correspondents
    //
    //        tableView.reloadData()
    //        _searchBar.resignFirstResponder()
    //    }
    //
    //    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    //        _searchBar.showsCancelButton = true
    //    }
    //
    //    func searchBarResultsListButtonClicked(searchBar: UISearchBar) {
    //        resignFirstResponder()
    //    }
    //
    //    func searchBar(searchBar: UISearchBar, textDidChange _searchText: String) {
    //        if _searchText == "" {
    //            _displayList = _correspondents
    //        }
    //        else {
    //            let predicate :NSPredicate = NSPredicate(format: "SELF.name contains[c] %@",_searchText)
    //            _displayList = (_correspondents as NSArray).filteredArrayUsingPredicate(predicate)
    //        }
    //
    //        tableView.reloadData()
    //    }
    
    // MARK: - Table View Data Sourse
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return _displayList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : TransactionOverviewCorrespondentTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("correspondent") as! TransactionOverviewCorrespondentTableViewCell
        let cellData  : Correspondent = _displayList[indexPath.row] as! Correspondent
        let transaction :TransferTransaction? = cellData.transaction
        
        cell.name.text = "  " + cellData.name
        
        if transaction != nil {
            cell.message.text = transaction!.message.getMessageString() ?? "ENCRYPTED_MESSAGE".localized()
        }
        else {
            cell.message.text = ""
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var timeStamp = Double(transaction!.timeStamp )
        
        timeStamp += genesis_block_time
        
        if dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: timeStamp)) == dateFormatter.stringFromDate(NSDate()) {
            dateFormatter.dateFormat = "HH:mm"
        }
        
        cell.date.text = ((transaction?.id == nil) ? ("UNCONFIRMED_DASHBOARD".localized() + " ") : "") + dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: timeStamp))
        
        var color :UIColor!
        var vector :String = ""
        if transaction?.recipient != _account_address! {
            color = UIColor.redColor()
            vector = "-"
        } else if AddressGenerator.generateAddress(transaction!.signer) ==  _account_address {
            color = UIColor(red: 142 / 255, green: 142 / 255, blue: 142 / 255, alpha: 1)
            vector = "±"
        } else {
            color = UIColor(red: 65/256, green: 206/256, blue: 123/256, alpha: 1)
            vector = "+"
        }
        
        let attribute = [NSForegroundColorAttributeName : color]
        
        let amount = vector + "\((transaction!.amount / 1000000).format()) XEM"
        
        cell.xems.attributedText = NSMutableAttributedString(string: amount, attributes: attribute)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        State.currentContact = _correspondents[indexPath.row] as Correspondent
        if walletData != nil {
            State.invoice = nil
            
//            var nextVC = ""
            if walletData!.cosignatories.count > 0 {
                performSegueWithIdentifier("showTransactionMultisignatureMessagesViewController", sender: nil)
            }
            else if walletData!.cosignatoryOf.count > 0 {
                performSegueWithIdentifier("showTransactionCosignatoryMessagesViewController", sender: nil)
                
            } else {
                performSegueWithIdentifier("showTransactionNormalMessagesViewController", sender: nil)
            }
        }
        else {
            self.tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        }
    }
    
    func segueToTransactionSendViewController() {
        
        performSegueWithIdentifier("showTransactionSendViewController", sender: nil)
    }
}
