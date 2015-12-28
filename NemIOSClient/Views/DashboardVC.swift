import UIKit

protocol DashboardVCDelegate {
    func switchToPage(page :String)
}

class DashboardVC: AbstractViewController, MainVCDelegate, DashboardVCDelegate
{
    @IBOutlet weak var messagesButton: DashboardButtonBox!
    @IBOutlet weak var addressBookButton: DashboardButtonBox!
    @IBOutlet weak var qrButton: DashboardButtonBox!
    @IBOutlet weak var moreButton: DashboardButtonBox!
    
    // MARK: - Load Methods
    private var _pages :DashboardContainer = DashboardContainer()
    private let _greenColor :UIColor = UIColor(red: 65/256, green: 206/256, blue: 123/256, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesButton.setTitle("MESSAGES".localized(), forState: UIControlState.Normal)
        addressBookButton.setTitle("ADDRESS_BOOK".localized(), forState: UIControlState.Normal)
        qrButton.setTitle("QR".localized(), forState: UIControlState.Normal)
        moreButton.setTitle("MORE".localized(), forState: UIControlState.Normal)
        
        changeState(State.toVC)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if(segue.identifier == "mainContainer") {
            _pages = segue.destinationViewController as! DashboardContainer
            _pages.delegate = self
        }
    }
    
    // MARK: - IBAction

    @IBAction func messagesButtonTouchUpInside(sender: AnyObject) {
        self.switchToPage(SegueToMessages)
    }
    
    @IBAction func addressBookButtonTouchUpInside(sender: AnyObject) {
        self.switchToPage(SegueToAddressBook)
    }
    //MARK: - Navigation Methods
    
    final func switchToPage(page :String) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(page)
        }
    }
    
    //MARK: - MainVCdDelegate Methods
    
    final func changeState(page: String){
        switch page {
        case    SegueToMessages, SegueToMessageVC, SegueToMessageMultisignVC,
        SegueToMessageCosignatoryVC, SegueToPasswordValidation, SegueToSendTransaction,
        SegueToUnconfirmedTransactionVC:
            messagesButton.setImage(UIImage(named: "message_active"), forState: UIControlState.Normal)
            addressBookButton.setImage(UIImage(named: "adress_passive"), forState: UIControlState.Normal)
            qrButton.setImage(UIImage(named: "qr_passive"), forState: UIControlState.Normal)
            
            messagesButton.setTitleColor(_greenColor, forState: UIControlState.Normal)
            addressBookButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            qrButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            
        case SegueToAddressBook:
            messagesButton.setImage(UIImage(named: "message_passive"), forState: UIControlState.Normal)
            addressBookButton.setImage(UIImage(named: "adress_active"), forState: UIControlState.Normal)
            qrButton.setImage(UIImage(named: "qr_passive"), forState: UIControlState.Normal)
            
            messagesButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            addressBookButton.setTitleColor(_greenColor, forState: UIControlState.Normal)
            qrButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            
        case SegueToQRController, SegueToUserInfo, SegueToCreateInvoice, SegueToCreateInvoiceResult, SegueToScanQR:
            messagesButton.setImage(UIImage(named: "message_passive"), forState: UIControlState.Normal)
            addressBookButton.setImage(UIImage(named: "adress_passive"), forState: UIControlState.Normal)
            qrButton.setImage(UIImage(named: "qr_active"), forState: UIControlState.Normal)
            
            messagesButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            addressBookButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            qrButton.setTitleColor(_greenColor, forState: UIControlState.Normal)
            
        default:
            break
        }
    }
    
    final func pageSelected(page :String){
        changeState(page)
        _pages.changePage(page)
    }
        
    @IBAction func qrButtonTouchUpInside(sender: AnyObject) {
        
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToUserInfo)
        }
    }
    
    @IBAction func moreButtonTouchUpInside(sender: AnyObject) {
        
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToMainMenu)
        }
    }

}
