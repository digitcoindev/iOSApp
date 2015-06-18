import UIKit

class MainContainerVC: UIViewController
{
    let dataManager :CoreDataManager = CoreDataManager()
    var lastVC :String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        var wallets :[Wallet] = dataManager.getWallets()
        
        if(wallets.count == 0)
        {
            lastVC = SegueToAddAccountVC
            
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToAddAccountVC )
            
            self.performSegueWithIdentifier(SegueToAddAccountVC, sender: self);
        }
        else 
        {
            lastVC = SegueToLoginVC

            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToLoginVC )
            
            self.performSegueWithIdentifier(SegueToLoginVC, sender: self);
        }
    }
    
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if (self.childViewControllers.count > 0)
        {
            NSNotificationCenter.defaultCenter().removeObserver(self.childViewControllers.first as! UIViewController)

            self.swapFromViewController(self.childViewControllers.first as! UIViewController, toViewController: segue.destinationViewController as! UIViewController)
        }
        else
        {
            self.addChildViewController(segue.destinationViewController as! UIViewController)
            (segue.destinationViewController as! UIViewController).view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
            
            self.view .addSubview((segue.destinationViewController as! UIViewController).view)
            segue.destinationViewController.didMoveToParentViewController(self)
        }
        
    }
    
    func swapFromViewController(fromViewController :UIViewController , toViewController :UIViewController )
    {
        toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        fromViewController.willMoveToParentViewController(nil)
        
        self.addChildViewController(toViewController)
        self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.5, options: UIViewAnimationOptions.TransitionNone
            , animations:
            {
                value in
            }
            , completion:
            {
                finish in
                NSNotificationCenter.defaultCenter().removeObserver(fromViewController)
                fromViewController.removeFromParentViewController()
                toViewController.didMoveToParentViewController(self)
        })
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        for vc in self.childViewControllers
        {
            NSNotificationCenter.defaultCenter().removeObserver(vc as! UIViewController)
            
            (vc as! UIViewController).removeFromParentViewController()
        }
    }
    
    final func changePage(page :String)
    {
        if(page != lastVC )
        {
            lastVC = page
            
            switch(page)
                {
                
            case SegueToMainMenu:
                self.performSegueWithIdentifier(SegueToMainMenu, sender: nil)
                
            case SegueToRegistrationVC:
                self.performSegueWithIdentifier(SegueToRegistrationVC, sender: nil)
                
            case SegueToLoginVC:
                self.performSegueWithIdentifier(SegueToLoginVC, sender: nil)
                
            case SegueToServerVC:
                self.performSegueWithIdentifier(SegueToServerVC, sender: nil)
                
            case SegueToDashboard:
                self.performSegueWithIdentifier(SegueToDashboard, sender: nil)
                                
            case SegueToAddAccountVC:
                self.performSegueWithIdentifier(SegueToAddAccountVC, sender: nil)
                               
            case SegueToImportFromQR:
                self.performSegueWithIdentifier(SegueToImportFromQR, sender: nil)
                
            case SegueToImportFromKey:
                self.performSegueWithIdentifier(SegueToImportFromKey, sender: nil)
                
            case SegueToProfile:
                self.performSegueWithIdentifier(SegueToProfile, sender: nil)
                
            case SegueToProfileMultisig:
                self.performSegueWithIdentifier(SegueToProfileMultisig, sender: nil)
                
            case SegueToProfileCosignatoryOf:
                self.performSegueWithIdentifier(SegueToProfileCosignatoryOf, sender: nil)
                
            case SegueToGoogleMap:
                self.performSegueWithIdentifier(SegueToGoogleMap, sender: nil)
                
            case SegueTomultisigAccountManager:
                self.performSegueWithIdentifier(SegueTomultisigAccountManager, sender: nil)
                
            case SegueToHistoryVC:
                self.performSegueWithIdentifier(SegueToHistoryVC, sender: nil)
                
            case SegueToExportAccount:
                self.performSegueWithIdentifier(SegueToExportAccount, sender: nil)
                
            case SegueToPasswordValidation , SegueToUnconfirmedTransactionVC , SegueToSendTransaction , SegueToMessageVC , SegueToMessageMultisignVC , SegueToAddressBook , SegueToUserInfo , SegueToQRCode , SegueToImportFromQR , SegueToMessages , SegueToCreateQRInput , SegueToCreateQRResult ,SegueToScanQR:
                
                State.toVC = page as String
                NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToDashboard )

                break
                
            default:
                break
            }
        }
    }
}