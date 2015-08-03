import UIKit

class ServerViewController: AbstractViewController
{
    @IBOutlet weak var predefinedBtn: UIButton!
    @IBOutlet weak var customBtn: UIButton!
    @IBOutlet weak var container: UIView!
    
    
    var arrow: UIButton!
    
    var pages :ServerContainerVC = ServerContainerVC();
    
    let dataManager : CoreDataManager = CoreDataManager()
    var servers : NSArray = NSArray()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        predefinedBtn.highlighted = false
        customBtn.highlighted = true
        
        if State.fromVC != SegueToServerVC
        {
            State.fromVC = SegueToServerVC
        }
        
        State.currentVC = SegueToServerVC

        servers = dataManager.getServers()
        
        var arrowImg :UIImage = UIImage(named: "tab_dropdown_arrow.png")!
        
        arrow = UIButton(frame: CGRect(x: 0, y: 0, width: arrowImg.size.width as CGFloat, height:  arrowImg.size.height as CGFloat))
        arrow.setBackgroundImage(arrowImg, forState: UIControlState.Normal)
        arrow.highlighted = true
        
        NSNotificationCenter.defaultCenter().postNotificationName("Title", object:"Servers")

        self.view.addSubview(arrow)
        
    }
    
    deinit
    {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if(segue.identifier == "serverContainer")
        {
            pages = segue.destinationViewController as! ServerContainerVC
        }
    }

    override func viewDidAppear(animated: Bool)
    {
        arrow.layer.frame.origin = CGPoint(x: self.view.frame.width / 4 , y:  predefinedBtn.frame.origin.y + predefinedBtn.frame.height)
    }
    
    @IBAction func predefinedSector(sender: AnyObject)
    {
        arrow.layer.frame.origin = CGPoint(x: predefinedBtn.frame.origin.x + predefinedBtn.frame.width / 2 , y:  predefinedBtn.frame.origin.y + predefinedBtn.frame.height )
        
    
        predefinedBtn.highlighted = false
        customBtn.highlighted = true
        
        if pages.curentPage != 0
        {
            pages.changePage(0)
        }
    }
    
    @IBAction func customServer(sender: AnyObject)
    {
        arrow.layer.frame.origin = CGPoint(x: customBtn.frame.origin.x + customBtn.frame.width / 2 , y:  customBtn.frame.origin.y + customBtn.frame.height  )

        predefinedBtn.highlighted = true
        customBtn.highlighted = false
        
        
        if pages.curentPage != 1
        {
            pages.changePage(1)
        }
    }
}
