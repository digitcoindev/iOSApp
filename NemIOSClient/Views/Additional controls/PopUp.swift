import UIKit

class PopUp: UIViewController
{
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var descriptionLable: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var popupView: UIView!

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
    {
        super.init(nibName: "PopUp", bundle: nil)
    }
    
    init()
    {
        super.init(nibName: "PopUp", bundle: nil)
    }
    
    func showIn(inView view :UIView)
    {
        self.popupView.layer.cornerRadius = 10
        self.confirmButton.layer.cornerRadius = 5
        
        var screen = UIScreen.mainScreen().bounds
        var selfRect :CGRect = CGRectMake( 0 , 0, screen.width  , screen.height)
        self.view.frame = selfRect
        
        view.addSubview(self.view)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }


}
