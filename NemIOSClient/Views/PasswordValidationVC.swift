import UIKit

class PasswordValidationVC: UIViewController
{
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirm: UIButton!
    
    var showKeyboard :Bool = true
    var currentField :UITextField!
    let dataMeneger: CoreDataManager  = CoreDataManager()

    override func viewDidLoad()
    {
        super.viewDidLoad()

        State.currentVC = SegueToPasswordValidation
        
        var center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        currentField = password
        password.layer.cornerRadius = 2
        confirm.layer.cornerRadius = 2
    }

    @IBAction func passwordValidation(sender: AnyObject)
    {        
        if( password.text == HashManager.AES256Decrypt(State.currentWallet!.password) )
        {
            NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:State.toVC )
        }
    }
    
    @IBAction func hideKeyBoard(sender: AnyObject)
    {
        (sender as UITextField).becomeFirstResponder()
    }
    
    final func keyboardWillShow(notification: NSNotification)
    {
        if(showKeyboard)
        {
            var info:NSDictionary = notification.userInfo!
            var keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
            
            var keyboardHeight:CGFloat = keyboardSize.height
            
            var animationDuration = 0.1
            
            if (keyboardHeight > (currentField.frame.origin.y - 5))
            {
                keyboardHeight = (currentField.frame.origin.y - 5 )as CGFloat
            }
            
            UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.view.frame = CGRectMake(0, -keyboardHeight , self.view.bounds.width, self.view.bounds.height)
                }, completion: nil)
            
        }
    }
    
    final func keyboardWillHide(notification: NSNotification)
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
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

}
