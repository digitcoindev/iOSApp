import UIKit

class ServerCustomVC: UIViewController
{
    @IBOutlet weak var protocolType: UITextField!
    @IBOutlet weak var serverAddress: UITextField!
    @IBOutlet weak var serverPort: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    var showKeyboard :Bool = true
    var currentField :UITextField!
    
    var state :String = "none"
    var timer :NSTimer!
    var newServer :Server? = nil
    
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
        observer.postNotificationName("Title", object:"Create server" )

        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "manageState", userInfo: nil, repeats: true)
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    final func manageState()
    {
        switch (state)
        {
        case "Confirmed" :
            
            var loadData :LoadData = dataManager.getLoadData()
            
            loadData.currentServer = newServer!
            dataManager.commit()
            
            State.currentServer = dataManager.getServers().last!
            
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:State.lastVC )
            
        case "Denied" :
            State.currentServer = nil

            var alert :UIAlertView = UIAlertView(title: "Info", message: "This server is currently unavailable.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        default :
            break
        }
        
        self.state = "none"
    }
    
    final func serverConfirmed(notification: NSNotification)
    {
        self.state = "Confirmed"
    }
    
    final func serverDenied(notification: NSNotification)
    {
        self.state = "Denied"
    }
    
    @IBAction func chouseTextField(sender: AnyObject)
    {
        currentField = protocolType
    }
    
    @IBAction func hideKeyBoard(sender: AnyObject)
    {
        (sender as! UITextField).becomeFirstResponder()

    }
    
    @IBAction func addServer(sender: AnyObject)
    {
        if serverAddress.text == "" || serverPort.text == "" || protocolType.text == ""
        {
            var alert :UIAlertView = UIAlertView(title: "Info", message: "To add new server you must fill all fields", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
        else if protocolType.text != "http"
        {
            var alert :UIAlertView = UIAlertView(title: "Info", message: "Available only \"http\" protocol type.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
        else
        {
            var servers :[Server] = dataManager.getServers()
            newServer = nil
            
            for server in servers
            {
                if server.protocolType == protocolType.text && server.address == serverAddress.text && server.port == serverPort.text
                {
                    newServer = server
                    
                    break
                }
            }
            
            if newServer == nil
            {
                newServer = dataManager.addServer(protocolType.text, address: serverAddress.text ,port: serverPort.text)
            }
            
            apiManager.heartbeat(dataManager.getServers().last!)
            
            serverAddress.text = ""
            protocolType.text = "http"
            serverPort.text = "7890"
        }
    }
    
    override func didMoveToParentViewController(parent: UIViewController?)
    {
        if parent == nil
        {
            observer.removeObserver(self, name:"heartbeatSuccessed", object:nil)
            observer.removeObserver(self, name:"heartbeatDenied", object:nil)
        }
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
            var keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            
            var keyboardHeight:CGFloat = keyboardSize.height
            
            var animationDuration = 0.1
            if currentField != nil
            {
                if (keyboardHeight > (currentField.frame.origin.y - 5))
                {
                    keyboardHeight = currentField.frame.origin.y as CGFloat
                }
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
            var keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            
            var keyboardHeight:CGFloat = keyboardSize.height
            
            var animationDuration:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! CGFloat
            
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.view.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
                    
                }, completion: nil)
        }
    }
}
