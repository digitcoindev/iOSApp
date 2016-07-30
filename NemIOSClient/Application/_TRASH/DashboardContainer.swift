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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
//        if self.delegate != nil {
//            (segue.destinationViewController as! UIViewController).delegate = self.delegate
//        }
        
        if (self.childViewControllers.count > 0) {
            self.swapFromViewController(self.childViewControllers.first!, toViewController: segue.destinationViewController)
        }
        else {
            self.addChildViewController(segue.destinationViewController )
            (segue.destinationViewController ).view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
            self.view.addSubview((segue.destinationViewController ).view)
            segue.destinationViewController.didMoveToParentViewController(self)
        }
        
    }
    
    func swapFromViewController(fromViewController :UIViewController , toViewController :UIViewController ) {
        toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        fromViewController.willMoveToParentViewController(nil)
        self.addChildViewController(toViewController)
        self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.5, options: UIViewAnimationOptions.TransitionNone, animations: {
                value in
            }
            , completion: {
                finish in
                
                fromViewController.removeFromParentViewController()
                toViewController.didMoveToParentViewController(self)
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
