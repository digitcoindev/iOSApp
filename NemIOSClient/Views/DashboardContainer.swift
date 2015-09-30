import UIKit

class DashboardContainer: AbstractViewController
{
    //MARK: - Private Variables

    let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()
    
    //MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.performSegueWithIdentifier(State.toVC, sender: self);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if self.delegate != nil {
            (segue.destinationViewController as! AbstractViewController).delegate = self.delegate
        }
        
        if (self.childViewControllers.count > 0) {
            self.swapFromViewController(self.childViewControllers.first!, toViewController: segue.destinationViewController)
        }
        else {
            self.addChildViewController(segue.destinationViewController )
            (segue.destinationViewController ).view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
            self.view .addSubview((segue.destinationViewController ).view)
            segue.destinationViewController.didMoveToParentViewController(self)
        }
        
    }
    
    func swapFromViewController(fromViewController :UIViewController , toViewController :UIViewController ) {
        toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        fromViewController.willMoveToParentViewController(nil)
        self.addChildViewController(toViewController)
        self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {
                value in
            }
            , completion: {
                finish in
                
                fromViewController.removeFromParentViewController()
                toViewController.didMoveToParentViewController(self)
        })
    }
    
    //MARK: - Navigation Methods
    
    final func changePage(page :String) {
        switch(page) {
            
        case    SegueToMessages, SegueToQRCode, SegueToUserInfo, SegueToAddressBook, SegueToMessageVC, SegueToMessageMultisignVC,
                SegueToMessageCosignatoryVC, SegueToPasswordValidation, SegueToCreateQRInput, SegueToCreateQRResult, SegueToScanQR, SegueToSendTransaction,
                SegueToUnconfirmedTransactionVC:
            
            self.performSegueWithIdentifier(page, sender: nil)
            
        default:
            
            if self.delegate != nil && self.delegate!.respondsToSelector("switchToPage:") {
                (self.delegate as! DashboardVCDelegate).switchToPage(page)
            }
        }
    }
}
