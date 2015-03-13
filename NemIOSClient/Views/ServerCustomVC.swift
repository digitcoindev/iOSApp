import UIKit

class ServerCustomVC: UIViewController
{
    @IBOutlet weak var protocolType: UITextField!
    @IBOutlet weak var serverAddress: UITextField!
    @IBOutlet weak var serverPort: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    var showKeyboard :Bool = true
    var currentField :UITextField!
    
    var apiManager :APIManager = APIManager()
    let dataManager :CoreDataManager = CoreDataManager()
    let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        observer.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        observer.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        observer.addObserver(self, selector: "serverConfirmed:", name: "heartbeatSuccessed", object: nil)
        observer.addObserver(self, selector: "serverDenied:", name: "heartbeatDenied", object: nil)
    }
    
    final func serverConfirmed(notification: NSNotification)
    {
        State.currentServer = dataManager.getServers().last!
    }
    
    final func serverDenied(notification: NSNotification)
    {
        State.currentServer = dataManager.getServers().last!   // For tests

        var alert :UIAlertView = UIAlertView(title: "Info", message: "This server is currently anavailable.", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }    
    
    @IBAction func chouseTextField(sender: AnyObject)
    {
        currentField = protocolType
    }
    
    @IBAction func hideKeyBoard(sender: AnyObject)
    {
        (sender as UITextField).becomeFirstResponder()

    }
    
    @IBAction func addServer(sender: AnyObject)
    {
        apiManager.heartbeat(dataManager.addServer(protocolType.text, address: serverAddress.text ,port: serverPort.text))

        serverAddress.text = ""
        protocolType.text = ""
        serverPort.text = ""
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        if(showKeyboard)
        {
            var info:NSDictionary = notification.userInfo!
            var keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
            
            var keyboardHeight:CGFloat = keyboardSize.height
            
            var animationDuration = 0.1
            
            if (keyboardHeight > (currentField.frame.origin.y - 5))
            {
                keyboardHeight = currentField.frame.origin.y as CGFloat
            }
            
            UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.view.frame = CGRectMake(0, -keyboardHeight , self.view.bounds.width, self.view.bounds.height)
                }, completion: nil)
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        if(showKeyboard)
        {
            var info:NSDictionary = notification.userInfo!
            var keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
            
            var keyboardHeight:CGFloat = keyboardSize.height
            
            var animationDuration:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as CGFloat
            
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.view.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
                    
                }, completion: nil)
        }
    }
}
