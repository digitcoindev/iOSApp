import UIKit

class MainContainerVC: AbstractViewController
{
    //MARK: - Private Variables

    private let _dataManager :CoreDataManager = CoreDataManager()
    
    //MARK: - Load Methods

    override func viewDidLoad(){
        super.viewDidLoad()
        
        let wallets :[Wallet] = _dataManager.getWallets()
        let loadData = _dataManager.getLoadData()
        
//        if loadData.password == nil || loadData.salt == nil {
//            self.performSegueWithIdentifier(SegueToCreatePassword, sender: self)
//            return
//        }
//        
//        if(wallets.count == 0) {
//            State.nextVC = SegueToAddAccountVC
//            self.performSegueWithIdentifier(SegueToAddAccountVC, sender: self)
//        }
//        else  {
//            
//            if State.currentWallet != nil && State.currentServer != nil{
//                State.toVC = SegueToMessages
//                State.nextVC = SegueToDashboard
//
//            } else {
//                State.nextVC = SegueToLoginVC
//            }
//        }
//        
//        self.performSegueWithIdentifier(SegueToPasswordValidation, sender: self)

    }
    
    override func delegateIsSetted(){
        for vc in self.childViewControllers {
            (vc as! AbstractViewController).delegate = self.delegate
        }
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!){
//        if self.delegate != nil {
//            (segue.destinationViewController as! AbstractViewController).delegate = self.delegate
//        }
//        
//        if (self.childViewControllers.count > 0) {
//            self.swapFromViewController(self.childViewControllers.first!, toViewController: segue.destinationViewController)
//        }
//        else {
//            self.addChildViewController(segue.destinationViewController )
//            (segue.destinationViewController ).view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
//            
//            self.view .addSubview((segue.destinationViewController ).view)
//            segue.destinationViewController.didMoveToParentViewController(self)
//        }
        
    }
    
    func swapFromViewController(fromViewController :UIViewController , toViewController :UIViewController ){
        toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        NSNotificationCenter().removeObserver(self)
        fromViewController.willMoveToParentViewController(nil)
        
        self.addChildViewController(toViewController)
        self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.5, options: UIViewAnimationOptions.TransitionNone
            , animations: {
                value in
            }
            , completion: {
                finish in
                
                fromViewController.removeFromParentViewController()
                toViewController.didMoveToParentViewController(self)
            })
    }
    
    //MARK: - Navigation Methods
    
    final func changePage(page :String){
        if(page != State.currentVC ) {
            
            switch(page) {
                
            case SegueToRegistrationVC, SegueToLoginVC, SegueToServerVC, SegueToDashboard, SegueToAddAccountVC,  SegueToImportFromQR, SegueToImportFromKey, SegueToSettings, SegueToMainMenu, SegueToExportAccount, SegueToPasswordValidation:
                self.performSegueWithIdentifier(page, sender: nil)
                
            case SegueToPasswordExport, SegueToUnconfirmedTransactionVC,  SegueToSendTransaction, SegueToMessageVC, SegueToMessageMultisignVC,  SegueToAddressBook, SegueToUserInfo, SegueToImportFromQR,  SegueToMessages, SegueToCreateInvoice, SegueToCreateInvoiceResult, SegueToScanQR, SegueToQRController, SegueToHarvestDetails, SegueToHistoryVC, SegueToGoogleMap, SegueTomultisigAccountManager:
                
                State.toVC = page as String
                
                if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
                    (self.delegate as! MainVCDelegate).pageSelected(SegueToDashboard)
                }
                
                break
                
            default:
                break
            }
        }
    }
}