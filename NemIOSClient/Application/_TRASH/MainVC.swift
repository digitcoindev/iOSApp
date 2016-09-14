import UIKit

@objc protocol MainVCDelegate
{
    func pageSelected(_ page :String)
}

class MainVC: UIViewController , MainVCDelegate, APIManagerDelegate
{
    
    //MARK: - Private Variables

    fileprivate var _pages :MainContainerVC = MainContainerVC()
    fileprivate let _apiManager :APIManager = APIManager()
//    private let _dataManager : CoreDataManager = CoreDataManager()

    //MARK: - Load Methods
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        _apiManager.delegate = self
        self.view.isMultipleTouchEnabled = false
//        State.currentServer = nil
        
//        let servers = self._dataManager.getServers()
//        for server in servers {
//            _apiManager.heartbeat(server)
//        }
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    //MARK: - Segue Helper
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if(segue.identifier == "mainContainer") {
            _pages = segue.destination as! MainContainerVC
//            _pages.delegate = self
        }
    }
    
    //MARK: - MainVCdDelegate Methods
    
    final func pageSelected(_ page :String){
//        _pages.changePage(page)
    }
    
    //MARK: - APIManagerDelegate Methods
    
    final func heartbeatResponceFromServer(_ server :Server ,successed :Bool) {
        if successed && State.currentServer == nil {
//            State.currentServer = server
            
//            let loadData :LoadData = _dataManager.getLoadData()
            
//            loadData.currentServer = State.currentServer!
//            _dataManager.commit()
        }
    }
}
