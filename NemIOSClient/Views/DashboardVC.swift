import UIKit

class DashboardVC: AbstractViewController
{
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.currentVC = SegueToDashboard
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if(segue.identifier == "mainContainer") {
            var container = segue.destinationViewController as! DashboardContainer
            container.delegate = self.delegate
        }
    }
    
    // MARK: - IBAction

    @IBAction func messagesButtonTouchUpInside(sender: AnyObject) {
        
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToMessages)
        }
    }
    
    @IBAction func addressBookButtonTouchUpInside(sender: AnyObject) {
        
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToAddressBook)
        }
    }
    
//    @IBAction func inputAddress(sender: UITextField)
//    {
//        if sender.text != ""
//        {
//            var find :Bool = false
//            
//            for correspondetn in correspondents
//            {
//                if correspondetn.public_key == sender.text
//                {
//                    State.currentContact = correspondetn as Correspondent
//                    State.toVC = SegueToMessageVC
//                    
//                    find = true
//                    
//                    NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToPasswordValidation )
//                }
//            }
//            
//            if !find
//            {
//                State.currentContact = dataManager.addCorrespondent(sender.text, name: sender.text , address : sender.text ,owner: State.currentWallet!)
//                State.toVC = SegueToMessageVC
//                
//                NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToPasswordValidation )
//            }
//        }
//    }
//    
//    @IBAction func addressBook(sender: AnyObject)
//    {
//        if AddressBookManager.isAllowed
//        {
//            State.toVC = SegueToMessages
//            
//            NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToAddressBook )        }
//        else
//        {
//            var alert :UIAlertView = UIAlertView(title: NSLocalizedString("INFO", comment: "Title"), message: "Contacts is unavailable.\nTo allow contacts follow to this directory\nSettings -> Privacy -> Contacts.", delegate: self, cancelButtonTitle: "OK")
//            alert.show()
//        }
//    }

    
    @IBAction func qrButtonTouchUpInside(sender: AnyObject) {
        
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToScanQR)
        }
    }
    
    @IBAction func moreButtonTouchUpInside(sender: AnyObject) {
        
        
    }

}
