import UIKit

class MainVC: UIViewController
{
    
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()
    
    var pages :MainContainerVC = MainContainerVC()
    var deviceData :plistFileManager = plistFileManager()

    var pagesTitles :NSMutableArray = NSMutableArray()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        
        
        observer.addObserver(self, selector: "pageSelected:", name: "MenuPage", object: nil)
        observer.addObserver(self, selector: "changeTitle:", name: "Title", object: nil)
                
        backBtn.hidden = true
        
        pagesTitles  = deviceData.getMenuItems()
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if(segue.identifier == "mainContainer")
        {
            pages = segue.destinationViewController as MainContainerVC
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func menu(sender: AnyObject)
    {
        status.text = SegueToMainMenu as String
        
        if State.currentVC != SegueToMainMenu
        {
            pages.changePage(SegueToMainMenu)
        }
        else
        {
            pages.changePage(State.fromVC!)
        }
    }
    
    @IBAction func backVC(sender: AnyObject)
    {
        if State.countVC <= 2
        {
            backBtn.hidden = true
        }
        
        pages.changePage(State.lastVC)
    }
    
    final func changeTitle(notification: NSNotification)
    {
        status.text = notification.object as? String
    }
    
    final func pageSelected(notification: NSNotification)
    {
        if State.countVC >= 1
        {
            backBtn.hidden = false
        }
        
        pages.changePage(notification.object as String)
    }
}
