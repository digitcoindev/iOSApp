import UIKit

protocol AddCustomServerDelegate
{
    func serverAdded(successfuly :Bool)
}

class AddCustomServerVC: AbstractViewController, APIManagerDelegate
{
    //MARK: - @IBOutlet

    @IBOutlet weak var protocolType: UITextField!
    @IBOutlet weak var serverAddress: UITextField!
    @IBOutlet weak var serverPort: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
    //MARK: - Private Variables
    
    private var _newServer :Server? = nil
    private let _apiManager :APIManager = APIManager()
    private let _dataManager :CoreDataManager = CoreDataManager()
    
    //MARK: - Load Methods

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.userInteractionEnabled = true

        var center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        _apiManager.delegate = self
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - @IBAction
    
    @IBAction func closePopUp(sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func textFieldChange(sender: UITextField)
    {
        switch sender {
        case protocolType:
            serverAddress.becomeFirstResponder()
            
        case serverAddress:
            serverPort.becomeFirstResponder()
            
        default:
            contentView.endEditing(false)
        }
    }
    
    @IBAction func addServer(sender: AnyObject)
    {
        if !Validate.stringNotEmpty(serverAddress.text) || !Validate.stringNotEmpty(serverPort.text) || !Validate.stringNotEmpty(protocolType.text)
        {
            var alert :UIAlertView = UIAlertView(title: NSLocalizedString("INFO", comment: "Title"), message: NSLocalizedString("FIELDS_EMPTY_ERROR", comment: "Description"), delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
        else if protocolType.text != "http"
        {
            var alert :UIAlertView = UIAlertView(title: NSLocalizedString("INFO", comment: "Title"), message: NSLocalizedString("SERVER_PROTOCOL_NOT_AVAILABLE", comment: "Description"), delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
        else
        {
            var servers :[Server] =  _dataManager.getServers()
            _newServer = nil
            
            for server in servers
            {
                if server.protocolType == protocolType.text && server.address == serverAddress.text && server.port == serverPort.text
                {
                    _newServer = server
                    
                    break
                }
            }
            
            if _newServer == nil
            {
                _newServer =  _dataManager.addServer(protocolType.text, address: serverAddress.text ,port: serverPort.text)
            }
                        
            if self.delegate != nil && self.delegate!.respondsToSelector("serverAdded:") {
                (self.delegate as! AddCustomServerDelegate).serverAdded(true)
            }
            
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            
            serverAddress.text = ""
            protocolType.text = "http"
            serverPort.text = "7890"
        }
    }
    
    //MARK: - Keyboard Delegate
    
    final func keyboardWillShow(notification: NSNotification) {
        var info:NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        var animationDuration = 0.1
        
        keyboardHeight -= self.view.frame.height - self.scroll.frame.height
        
        scroll.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight , 0)
        scroll.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight + 30, 0)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.scroll.contentInset = UIEdgeInsetsZero
        self.scroll.scrollIndicatorInsets = UIEdgeInsetsZero
    }
}
