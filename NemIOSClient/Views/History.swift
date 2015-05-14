//import UIKit
//
//class History: UIViewController
//{
//
//    
//    override func viewDidLoad()
//    {
////        super.viewDidLoad()
////        keyValidator.hidden = true
////        
////        self.tableView.tableFooterView = UIView(frame: CGRectZero)
////        self.tableView.layer.cornerRadius = 5
////        
////        var observer: NSNotificationCenter = NSNotificationCenter.defaultCenter()
////        
////        observer.addObserver(self, selector: "accountTransfersAllDenied:", name: "accountTransfersAllDenied", object: nil)
////        observer.addObserver(self, selector: "accountTransfersAllSuccessed:", name: "accountTransfersAllSuccessed", object: nil)
////        observer.addObserver(self, selector: "unconfirmedTransactionsDenied:", name: "unconfirmedTransactionsDenied", object: nil)
////        observer.addObserver(self, selector: "unconfirmedTransactionsSuccessed:", name: "unconfirmedTransactionsSuccessed", object: nil)
////        
////        addCosignatori.autocorrectionType = UITextAutocorrectionType.No
////        
////        if State.currentServer != nil
////        {
////            var address :String = AddressGenerator().generateAddressFromPrivateKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey))
////            
////            apiManager.accountTransfersAll(State.currentServer!, account_address: address)
////            apiManager.unconfirmedTransactions(State.currentServer!, account_address: address)
////            
////        }
////        else
////        {
////            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToServerTable )
////        }
////        
////        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "manageState", userInfo: nil, repeats: true)
//    }
//    
//    deinit
//    {
//        NSNotificationCenter.defaultCenter().removeObserver(self)
//    }
//    
//    override func didReceiveMemoryWarning()
//    {
//        super.didReceiveMemoryWarning()
//    }
//    
//    final func manageState()
//    {
////        switch (state.last!)
////        {
////        case "accountTransfersAllSuccessed" :
////            break
////            
////        case "accountGetSuccessed" :
////            var stateWallet = State.currentWallet!
////            userLogin.text = stateWallet.login
////            userAddress.text =  AddressGenerator().generateAddressFromPrivateKey(HashManager.AES256Decrypt(stateWallet.privateKey))
////            
////            
////        default :
////            break
////        }
//    }
//    
//    final func accountTransfersAllSuccessed(notification: NSNotification)
//    {
//        var data :[TransactionPostMetaData] = notification.object as! [TransactionPostMetaData]
//        
//        for var index = 0 ; index < data.count ; index++
//        {
//            if data[index].type != multisigAggregateModificationTransaction
//            {
//                data.removeAtIndex(index)
//                index--
//            }
//        }
//        
//        confirmedChanges = data
//        
//        state.append("accountTransfersAllSuccessed")
//    }
//    
//    final func unconfirmedTransactionsSuccessed(notification: NSNotification)
//    {
//        var data :[TransactionPostMetaData] = notification.object as! [TransactionPostMetaData]
//        
//        for var index = 0 ; index < data.count ; index++
//        {
//            if data[index].type != multisigAggregateModificationTransaction
//            {
//                data.removeAtIndex(index)
//                index--
//            }
//        }
//        
//        unconfirmedChanges = data
//        
//        state.append("unconfirmedTransactionsSuccessed")
//    }
//    
//    final func unconfirmedTransactionsDenied(notification: NSNotification)
//    {
//        state.append("unconfirmedTransactionsAllDenied")
//    }
//    
//    final func accountTransfersAllDenied(notification: NSNotification)
//    {
//        state.append("accountTransfersAllDenied")
//    }
//
//}
