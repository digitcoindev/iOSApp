import UIKit

@objc protocol MainVCDelegate
{
    func pageSelected(page :String)
}

class MainVC: AbstractViewController , MainVCDelegate
{
    
    //MARK: - Private Variables

    private var _pages :MainContainerVC = MainContainerVC()

    //MARK: - Load Methods

    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.view.multipleTouchEnabled = false
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle{
        return UIStatusBarStyle.LightContent
    }
    
    //MARK: - Segue Helper
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if(segue.identifier == "mainContainer") {
            _pages = segue.destinationViewController as! MainContainerVC
            _pages.delegate = self
        }
    }
    
    //MARK: - MainVCdDelegate Methods
    
    final func pageSelected(page :String){
        _pages.changePage(page)
    }

}
