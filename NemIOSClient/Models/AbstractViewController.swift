import UIKit

class AbstractViewController: UIViewController
{
    private var _delegate :AnyObject?
    
    var delegate :AnyObject?{
        set{
            self._delegate = newValue
            delegateIsSetted()
        }
        
        get{
            return self._delegate
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    func delegateIsSetted(){
        
    }
}
