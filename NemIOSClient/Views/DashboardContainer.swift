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
            self.swapFromViewController(self.childViewControllers.first as! UIViewController, toViewController: segue.destinationViewController as! UIViewController)
        }
        else {
            self.addChildViewController(segue.destinationViewController as! UIViewController)
            (segue.destinationViewController as! UIViewController).view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
            self.view .addSubview((segue.destinationViewController as! UIViewController).view)
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
            
        case SegueToMessages:
            self.performSegueWithIdentifier(SegueToMessages, sender: nil)
            break;
            
        case SegueToQRCode:
            self.performSegueWithIdentifier(SegueToQRCode, sender: nil)
            break;
            
        case SegueToUserInfo:
            self.performSegueWithIdentifier(SegueToUserInfo, sender: nil)
            break;
            
        case SegueToAddressBook:
            self.performSegueWithIdentifier(SegueToAddressBook, sender: nil)
            break;
            
        case SegueToMessageVC:
            self.performSegueWithIdentifier(SegueToMessageVC, sender: nil)
            
        case SegueToMessageMultisignVC:
            self.performSegueWithIdentifier(SegueToMessageMultisignVC, sender: nil)
            
        case SegueToPasswordValidation:
            self.performSegueWithIdentifier(SegueToPasswordValidation, sender: nil)
            
        case SegueToCreateQRInput:
            self.performSegueWithIdentifier(SegueToCreateQRInput, sender: nil)
            
        case SegueToCreateQRResult:
            self.performSegueWithIdentifier(SegueToCreateQRResult, sender: nil)
            
        case SegueToScanQR:
            self.performSegueWithIdentifier(SegueToScanQR, sender: nil)
            
        case SegueToSendTransaction:
            self.performSegueWithIdentifier(SegueToSendTransaction, sender: nil)
            
        case SegueToUnconfirmedTransactionVC:
                self.performSegueWithIdentifier(SegueToUnconfirmedTransactionVC, sender: nil)
            
        default:
            break;
        }
    }
}
