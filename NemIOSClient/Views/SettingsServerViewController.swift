import UIKit

class SettingsServerViewController: AbstractViewController, UITableViewDataSource, UITableViewDelegate, ServerCellDelegate, APIManagerDelegate, AddCustomServerDelegate
{
    // MARK: - Variables

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addServer: UIButton!
    
    private let _dataManager : CoreDataManager = CoreDataManager()
    private let _apiManager :APIManager = APIManager()
    private var _isEditing = false
    private var _alertShown :Bool = false
    private var _popUp :AbstractViewController? = nil

    var servers : [Server] = []

    // MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        _apiManager.delegate = self
        
        servers = _dataManager.getServers()
        title = "SERVER".localized()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "EDIT".localized(), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(editButtonTouchUpInside(_:)))
        
        addServer.setTitle("  " + "ADD_SERVER".localized(), forState: UIControlState.Normal)
        
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 10)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        State.currentVC = SegueToServerVC
    }
    
    // MARK: - IBAction

    @IBAction func addAccountTouchUpInside(sender: AnyObject) {
        showServerPopUp()
    }
    
    @IBAction func editButtonTouchUpInside(sender: AnyObject) {
        if _popUp != nil { return }

        _isEditing = !_isEditing
        
        let title = _isEditing ? "DONE".localized() : "EDIT".localized()
        tabBarController?.navigationItem.rightBarButtonItem!.title = title

        for cell in self.tableView.visibleCells {
            (cell as! ServerViewCell).inEditingState = _isEditing
            (cell as! ServerViewCell).actionButton.userInteractionEnabled = _isEditing
            (cell as! ServerViewCell).layoutCell(animated: true)
        }
    }
    
    // MARK: - TableViewDelegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : ServerViewCell = self.tableView.dequeueReusableCellWithIdentifier("serverCell") as! ServerViewCell
        cell.delegate = self
        
        let cellData  : Server = servers[indexPath.row]
        cell.serverName.text = "  " + cellData.protocolType + "://" + cellData.address + ":" + cellData.port
        if servers[indexPath.row] == State.currentServer {
            cell.isActiveServer = true
        }  else {
            cell.isActiveServer = false
        }
        
        cell.inEditingState = _isEditing
        cell.actionButton.userInteractionEnabled = _isEditing

        cell.layoutCell(animated: false)
//        let fileName = "server \(cellData.address).png"
//        let fileService = FileService()
//        if fileService.fileExist(fileName) {
//            cell.flagImageView.image = UIImage(contentsOfFile: fileName.path())
//        } else {
//            cell.flagImageView.image = UIImage(named: "unknown_server_icon")
//            if let url = NSURL(string: "http://api.hostip.info/flag.php?ip=\(cellData.address)") {
//                _apiManager.downloadImage(url) { (image) -> Void in
//                    
//                    fileService.createFileWithName(fileName, data: UIImagePNGRepresentation(image)!, responce: { (state) -> Void in
//                        if state == FileServiceResponceState.Successed {
//                            self.tableView.reloadData()
//                        }
//                    })
//                }
//            }
//        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !_isEditing {
            if  State.currentServer != nil {
                
                var oldIndex = 0
                
                for var i = 0 ; i < servers.count ; i += 1 {
                    if servers[i] == State.currentServer! {
                        oldIndex = i
                    }
                }
                
                let oldIndexPath = NSIndexPath(forRow: oldIndex, inSection: 0)
                
                if oldIndexPath != indexPath {
                    let serverCell = tableView.cellForRowAtIndexPath(oldIndexPath) as? ServerViewCell
                    
                    serverCell?.isActiveServer = false
                }
            }
            
            let selectedServer :Server = servers[indexPath.row]
            
            State.currentServer = selectedServer
            
            _apiManager.heartbeat(selectedServer)
        } else {
            let selectedServer :Server = servers[indexPath.row]

            showServerPopUp(selectedServer)
        }
    }
    
    private func showServerPopUp(server :Server? = nil)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let serverCustomVC :SettingsAddServerViewController =  storyboard.instantiateViewControllerWithIdentifier("SettingsAddServerViewController") as! SettingsAddServerViewController
        serverCustomVC.view.frame = CGRect(x: 0, y: view.frame.height, width: serverCustomVC.view.frame.width, height: serverCustomVC.view.frame.height - view.frame.height)
        serverCustomVC.view.layer.opacity = 0
        serverCustomVC.delegate = self
        
        if server != nil {
            serverCustomVC.newServer = server
            serverCustomVC.protocolType.text = server!.protocolType
            serverCustomVC.serverAddress.text = server!.address
            serverCustomVC.serverPort.text = server!.port
            serverCustomVC.saveBtn.setTitle("CHANGE_SERVER".localized(), forState: UIControlState.Normal)
        } else {
            serverCustomVC.saveBtn.setTitle("ADD_SERVER".localized(), forState: UIControlState.Normal)
        }
        
        _popUp = serverCustomVC
        self.view.addSubview(serverCustomVC.view)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            serverCustomVC.view.layer.opacity = 1
            }, completion: nil)
    }
    
    //MARK: - ServerCell Delegate
    
    func deleteCell(cell :UITableViewCell) {       
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: String(format: "DELETE_CONFIRMATION_MASSAGE_SERVERS".localized(), (cell as! ServerViewCell).serverName.text!), preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            let index :NSIndexPath = self.tableView.indexPathForCell(cell)!
            
            if index.row < self.servers.count {
                self._dataManager.deleteServer(server: self.servers[index.row])
                self.servers.removeAtIndex(index.row)
                
                self.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Left)
            }
            
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - AddCustomServerDelegate Methods
    
    func serverAdded(successfuly: Bool) {
        if successfuly {
            servers = _dataManager.getServers()
            tableView.reloadData()
        }
    }
    
    func popUpClosed(){
        if _popUp != nil {
            _popUp!.view.removeFromSuperview()
            _popUp!.removeFromParentViewController()
            _popUp = nil
        }
    }
    
    //MARK: - APIManagerDelegate Methods
    
    final func heartbeatResponceFromServer(server :Server ,successed :Bool) {
        if successed {
            State.currentServer = server
            _apiManager.timeSynchronize(server)
            
            let loadData :LoadData = _dataManager.getLoadData()
            
            loadData.currentServer = State.currentServer!
            _dataManager.commit()
            
            self.tableView.reloadData()
        } else {
            State.currentServer = nil
            if !_alertShown {
                _alertShown = true
                
                let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: "SERVER_UNAVAILABLE".localized(), preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self._alertShown = false

                    alert.dismissViewControllerAnimated(true, completion: nil)
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
}
