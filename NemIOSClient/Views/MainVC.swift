import UIKit

@objc protocol MainVCDelegate
{
    func pageSelected(page :String)
}

class MainVC: AbstractViewController , MainVCDelegate, APIManagerDelegate
{
    
    //MARK: - Private Variables

    private var _pages :MainContainerVC = MainContainerVC()
    private let _apiManager :APIManager = APIManager()
    private let _dataManager : CoreDataManager = CoreDataManager()

    //MARK: - Load Methods
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        _apiManager.delegate = self
        self.view.multipleTouchEnabled = false
        State.currentServer = nil
        
        let servers = self._dataManager.getServers()
        for server in servers {
            _apiManager.heartbeat(server)
        }
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
    
    //MARK: - APIManagerDelegate Methods
    
    final func heartbeatResponceFromServer(server :Server ,successed :Bool) {
        if successed && State.currentServer == nil {
            State.currentServer = server
            
            let loadData :LoadData = _dataManager.getLoadData()
            
            loadData.currentServer = State.currentServer!
            _dataManager.commit()
        }
    }
}
