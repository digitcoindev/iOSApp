////
////  TransactionUnconfirmedViewController.swift
////
////  This file is covered by the LICENSE file in the root of this project.
////  Copyright (c) 2016 NEM
////
//
//import UIKit
//
//class TransactionUnconfirmedViewController: UIViewController ,UITableViewDelegate, APIManagerDelegate
//{
//    @IBOutlet weak var tableView: UITableView!
//
//    
//    var walletData :AccountGetMetaData!
//    var unconfirmedTransactions  :[TransactionPostMetaData] = [TransactionPostMetaData]()
//    fileprivate var _apiManager :APIManager = APIManager()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        _apiManager.delegate = self
//        
//        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
//        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
//        
//    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
////        State.currentVC = SegueToUnconfirmedTransactionVC
//        
//        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
//        let publicKey = KeyGenerator.generatePublicKey(privateKey!)
//        let account_address = AddressGenerator.generateAddress(publicKey)
//        
//        _apiManager.accountGet(State.currentServer!, account_address: account_address)
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//        return unconfirmedTransactions.count
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let transaction :_MultisigTransaction = unconfirmedTransactions[indexPath.row] as! _MultisigTransaction
//        
//        switch (transaction.innerTransaction.type) {
//        case transferTransaction:
//            return 344
//            
//        case multisigAggregateModificationTransaction:
//            return 267
//            
//        default :
//            break
//        }
//        return 344
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
//        let transaction :_MultisigTransaction = unconfirmedTransactions[indexPath.row] as! _MultisigTransaction
//        
//        switch (transaction.innerTransaction.type) {
//        case transferTransaction:
//            let innerTransaction = (transaction.innerTransaction) as! _TransferTransaction
//            let cell : TransactionUnconfirmedTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "transferTransaction") as! TransactionUnconfirmedTableViewCell
//            cell.fromAccount.text = AddressGenerator.generateAddress(innerTransaction.signer).nemName()
//            cell.toAccount.text = innerTransaction.recipient.nemName()
//            cell.message.text = innerTransaction.message.getMessageString() ?? "ENCRYPTED_MESSAGE".localized()
//            cell.delegate = self
//            cell.xem.text = "\(innerTransaction.amount / 1000000) XEM"
//            
//            cell.tag = indexPath.row
//            
//            return cell
//            
//        case multisigAggregateModificationTransaction:
//            
//            let innerTrnsaction :AggregateModificationTransaction = transaction.innerTransaction as! AggregateModificationTransaction
//            let cell : TransactionUnconfirmedTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "multisigAggregateModificationTransaction") as! TransactionUnconfirmedTableViewCell
//            cell.delegate = self
//            cell.tag = indexPath.row
//            cell.fromAccount.text = AddressGenerator.generateAddress(innerTrnsaction.signer)
//            cell.toAccount.text = AddressGenerator.generateAddress(innerTrnsaction.signer)
//            
//            return cell
//            
//        default :
//            break
//        }
//        return UITableViewCell()
//    }
//    
//    final func confirmTransactionAtIndex(_ index: Int){
//        if unconfirmedTransactions.count > index {
//            let transaction :_MultisigTransaction = unconfirmedTransactions[index] as! _MultisigTransaction
//            
//            switch (transaction.innerTransaction.type) {
//            case transferTransaction:
//                
//                let sendTrans :_MultisigSignatureTransaction = _MultisigSignatureTransaction()
//                sendTrans.transactionHash = unconfirmedTransactions[index].data
//                let innerTrans :_TransferTransaction = transaction.innerTransaction as! _TransferTransaction
//                sendTrans.multisigAccountAddress = AddressGenerator.generateAddress(innerTrans.signer)
//                
//                sendTrans.timeStamp = Double(Int(TimeSynchronizator.nemTime))
//                sendTrans.fee = 6
//                sendTrans.deadline = Double(Int(TimeSynchronizator.nemTime + waitTime))
//                sendTrans.version = 1
//                sendTrans.signer = walletData.publicKey
//                
//                _apiManager.prepareAnnounce(State.currentServer!, transaction: sendTrans)
//                
//            case multisigAggregateModificationTransaction:
//                
//                let sendTrans :_MultisigSignatureTransaction = _MultisigSignatureTransaction()
//                sendTrans.transactionHash = unconfirmedTransactions[index].data
//                let innerTrans :AggregateModificationTransaction = transaction.innerTransaction as! AggregateModificationTransaction
//                sendTrans.multisigAccountAddress = AddressGenerator.generateAddress(innerTrans.signer)
//                
//                sendTrans.timeStamp = Double(Int(TimeSynchronizator.nemTime))
//                sendTrans.fee = 6
//                sendTrans.deadline = Double(Int(TimeSynchronizator.nemTime + waitTime))
//                sendTrans.version = 1
//                sendTrans.signer = walletData.publicKey
//                
//                _apiManager.prepareAnnounce(State.currentServer!, transaction: sendTrans)
//                
//            default :
//                break
//            }
//        }
//    }
//    
//    final func showTransactionAtIndex(_ index: Int){
//        var text :String = "ACCOUNT".localized() + " : "
//        
//        let transaction :AggregateModificationTransaction = (unconfirmedTransactions[index] as! _MultisigTransaction).innerTransaction as! AggregateModificationTransaction
//        
//        text += AddressGenerator.generateAddress(transaction.signer).nemName() + "\n"
//        
//        for modification in transaction.modifications {
//            let name = AddressGenerator.generateAddress(modification.publicKey).nemName()
//            if modification.modificationType == 1 {
//                text += "ADD" + " :\n"
//                text += name + "\n"
//            }
//            else {
//                text += "DELETE".localized() + " :\n"
//                text += name + "\n"
//            }
//        }
//        
//        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: text, preferredStyle: UIAlertControllerStyle.alert)
//        
//        let ok :UIAlertAction = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.destructive) {
//            alertAction -> Void in
//        }
//        
//        alert.addAction(ok)
//        self.present(alert, animated: true, completion: nil)
//    }
//    
//    fileprivate final func _showPopUp(_ message :String){
//        
//        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: message, preferredStyle: UIAlertControllerStyle.alert)
//        
//        let ok :UIAlertAction = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default) {
//            alertAction -> Void in
//            
//        }
//        
//        alert.addAction(ok)
//        self.present(alert, animated: true, completion: nil)
//    }
//    
//    // MARK: - APIManagerDelegate Methods
//    
//    final func accountGetResponceWithAccount(_ account: AccountGetMetaData?) {
//        if let responceAccount = account {
//            walletData = responceAccount
//            unconfirmedTransactions.removeAll(keepingCapacity: false)
//            _apiManager.unconfirmedTransactions(State.currentServer!, account_address: walletData.address)
//        }
//    }
//    
//    final func unconfirmedTransactionsResponceWithTransactions(_ data: [TransactionPostMetaData]?) {
//        if let data = data {
//            unconfirmedTransactions = data
//            let publicKey = KeyGenerator.generatePublicKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)!)
//            
//            
//            for i in 0..<unconfirmedTransactions.count {
//                if unconfirmedTransactions[i].type != multisigTransaction {
//                    unconfirmedTransactions.remove(at: i)
//                    i -= 1
//                }
//                else {
//                    let transaction :_MultisigTransaction = unconfirmedTransactions[i] as! _MultisigTransaction
//
//                    if transaction.innerTransaction.type != transferTransaction && transaction.innerTransaction.type != multisigAggregateModificationTransaction {
//                        unconfirmedTransactions.remove(at: i)
//                        i -= 1
//                        continue
//                    }
//                    
//                    if transaction.signer == walletData.publicKey{
//                        unconfirmedTransactions.remove(at: i)
//                        i -= 1
//                        continue
//                    }
//                    
//                    for sign in transaction.signatures {
//                        if publicKey == sign.signer
//                        {
//                            unconfirmedTransactions.remove(at: i)
//                            i -= 1
//                            break
//                        }
//                    }
//                }
//            }
//            DispatchQueue.main.async(execute: { () -> Void in
//                self.tableView.reloadData()
//            })
//        }
//    }
//    
//    func prepareAnnounceResponceWithTransactions(_ data: [TransactionPostMetaData]?) {
//        
//        var message :String = ""
//        if (data ?? []).isEmpty {
//            message = "TRANSACTION_ANOUNCE_FAILED".localized()
//        } else {
//            message = "TRANSACTION_ANOUNCE_SUCCESS".localized()
//            
//            if unconfirmedTransactions.count == 1 {
////                backButtonTouchUpInside(self)
//            } else {
//                _apiManager.accountGet(State.currentServer!, account_address: walletData.address)
//            }
//        }
//        
//        _showPopUp(message)
//    }
//}
