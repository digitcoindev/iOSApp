import UIKit

class DashboardContainer: UIViewController
{
    //MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        changePage(State.toVC)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
//        if self.delegate != nil {
//            (segue.destinationViewController as! UIViewController).delegate = self.delegate
//        }
        
        if (self.childViewControllers.count > 0) {
            self.swapFromViewController(self.childViewControllers.first!, toViewController: segue.destination)
        }
        else {
            self.addChildViewController(segue.destination )
            (segue.destination ).view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.view.addSubview((segue.destination ).view)
            segue.destination.didMove(toParentViewController: self)
        }
        
    }
    
    func swapFromViewController(_ fromViewController :UIViewController , toViewController :UIViewController ) {
        toViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        fromViewController.willMove(toParentViewController: nil)
        self.addChildViewController(toViewController)
        self.transition(from: fromViewController, to: toViewController, duration: 0.5, options: UIViewAnimationOptions(), animations: {
                value in
            }
            , completion: {
                finish in
                
                fromViewController.removeFromParentViewController()
                toViewController.didMove(toParentViewController: self)
        })
    }
    
    //MARK: - Navigation Methods
    
//    final func changePage(page :String) {
//        switch(page) {
//            
//        case    SegueToMessages, SegueToAddressBook, SegueToMessageVC, SegueToMessageMultisignVC,
//                SegueToMessageCosignatoryVC, SegueToPasswordExport, SegueToSendTransaction,
//                SegueToUnconfirmedTransactionVC, SegueToQRController, SegueToHarvestDetails, SegueToHistoryVC, SegueToGoogleMap, SegueTomultisigAccountManager:
//            
//            self.performSegueWithIdentifier(page, sender: nil)
//            
//        case  SegueToUserInfo, SegueToCreateInvoice, SegueToCreateInvoiceResult, SegueToScanQR :
//            
//            State.toVC = page
//            
//            self.performSegueWithIdentifier(SegueToQRController, sender: nil)
//            
//        default:
//            if (self.delegate as? AbstractViewController)!.delegate != nil && self.delegate!.delegate.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
//                ((self.delegate as! AbstractViewController).delegate as! MainVCDelegate).pageSelected(page)
//            }
//        }
//    }
}
