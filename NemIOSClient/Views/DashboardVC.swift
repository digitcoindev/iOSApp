import UIKit

protocol DashboardVCDelegate {
    func switchToPage(page :String)
}

class DashboardVC: AbstractViewController, MainVCDelegate, DashboardVCDelegate
{
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Load Methods
    private var _pages :DashboardContainer = DashboardContainer()

    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    final func pageSelected(page :String){
        _pages.changePage(page)
    }
        
    @IBAction func qrButtonTouchUpInside(sender: AnyObject) {
        
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToUserInfo)
        }
    }
    
    @IBAction func moreButtonTouchUpInside(sender: AnyObject) {
        
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToProfile)
        }
    }

}
