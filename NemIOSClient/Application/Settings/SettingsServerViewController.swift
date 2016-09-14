//
//  SettingsServerViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class SettingsServerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ServerCellDelegate, APIManagerDelegate, AddCustomServerDelegate
{
    // MARK: - Variables

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addServer: UIButton!
    
//    private let _dataManager : CoreDataManager = CoreDataManager()
    fileprivate let _apiManager :APIManager = APIManager()
    fileprivate var _isEditing = false
    fileprivate var _alertShown :Bool = false
    fileprivate var _popUp :UIViewController? = nil

    var servers : [Server] = []

    // MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        _apiManager.delegate = self
        
//        servers = _dataManager.getServers()
        title = "SERVER".localized()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "EDIT".localized(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(editButtonTouchUpInside(_:)))
        
        addServer.setTitle("  " + "ADD_SERVER".localized(), for: UIControlState())
        
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 10)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        State.currentVC = SegueToServerVC
    }
    
    // MARK: - IBAction

    @IBAction func addAccountTouchUpInside(_ sender: AnyObject) {
        showServerPopUp()
    }
    
    @IBAction func editButtonTouchUpInside(_ sender: AnyObject) {
        if _popUp != nil { return }

        _isEditing = !_isEditing
        
        let title = _isEditing ? "DONE".localized() : "EDIT".localized()
        tabBarController?.navigationItem.rightBarButtonItem!.title = title

        for cell in self.tableView.visibleCells {
            (cell as! ServerViewCell).inEditingState = _isEditing
            (cell as! ServerViewCell).actionButton.isUserInteractionEnabled = _isEditing
            (cell as! ServerViewCell).layoutCell(animated: true)
        }
    }
    
    // MARK: - TableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ServerViewCell = self.tableView.dequeueReusableCell(withIdentifier: "serverCell") as! ServerViewCell
        cell.delegate = self
        
        let cellData  : Server = servers[(indexPath as NSIndexPath).row]
        cell.serverName.text = "  " + cellData.protocolType + "://" + cellData.address + ":" + cellData.port
        if servers[(indexPath as NSIndexPath).row] == State.currentServer {
            cell.isActiveServer = true
        }  else {
            cell.isActiveServer = false
        }
        
        cell.inEditingState = _isEditing
        cell.actionButton.isUserInteractionEnabled = _isEditing

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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !_isEditing {
            if  State.currentServer != nil {
                
                var oldIndex = 0
                
                for i in 0  ..< servers.count {
                    if servers[i] == State.currentServer! {
                        oldIndex = i
                    }
                }
                
                let oldIndexPath = IndexPath(row: oldIndex, section: 0)
                
                if oldIndexPath != indexPath {
                    let serverCell = tableView.cellForRow(at: oldIndexPath) as? ServerViewCell
                    
                    serverCell?.isActiveServer = false
                }
            }
            
            let selectedServer :Server = servers[(indexPath as NSIndexPath).row]
            
//            State.currentServer = selectedServer
            
            _apiManager.heartbeat(selectedServer)
        } else {
            let selectedServer :Server = servers[(indexPath as NSIndexPath).row]

            showServerPopUp(selectedServer)
        }
    }
    
    fileprivate func showServerPopUp(_ server :Server? = nil)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let serverCustomVC :SettingsAddServerViewController =  storyboard.instantiateViewController(withIdentifier: "SettingsAddServerViewController") as! SettingsAddServerViewController
        serverCustomVC.view.frame = CGRect(x: 0, y: view.frame.height, width: serverCustomVC.view.frame.width, height: serverCustomVC.view.frame.height - view.frame.height)
        serverCustomVC.view.layer.opacity = 0
//        serverCustomVC.delegate = self
        
        if server != nil {
            serverCustomVC.newServer = server
            serverCustomVC.protocolType.text = server!.protocolType
            serverCustomVC.serverAddress.text = server!.address
            serverCustomVC.serverPort.text = server!.port
            serverCustomVC.saveBtn.setTitle("CHANGE_SERVER".localized(), for: UIControlState())
        } else {
            serverCustomVC.saveBtn.setTitle("ADD_SERVER".localized(), for: UIControlState())
        }
        
        _popUp = serverCustomVC
        self.view.addSubview(serverCustomVC.view)
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            serverCustomVC.view.layer.opacity = 1
            }, completion: nil)
    }
    
    //MARK: - ServerCell Delegate
    
    func deleteCell(_ cell :UITableViewCell) {       
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: String(format: "DELETE_CONFIRMATION_MASSAGE_SERVERS".localized(), (cell as! ServerViewCell).serverName.text!), preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let index :IndexPath = self.tableView.indexPath(for: cell)!
            
            if (index as NSIndexPath).row < self.servers.count {
//                self._dataManager.deleteServer(server: self.servers[index.row])
                self.servers.remove(at: (index as NSIndexPath).row)
                
                self.tableView.deleteRows(at: [index], with: UITableViewRowAnimation.left)
            }
            
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - AddCustomServerDelegate Methods
    
    func serverAdded(_ successfuly: Bool) {
        if successfuly {
//            servers = _dataManager.getServers()
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
    
    final func heartbeatResponceFromServer(_ server :Server ,successed :Bool) {
        if successed {
//            State.currentServer = server
            _apiManager.timeSynchronize(server)
            
//            let loadData :LoadData = _dataManager.getLoadData()
            
//            loadData.currentServer = State.currentServer!
//            _dataManager.commit()
            
            self.tableView.reloadData()
        } else {
//            State.currentServer = nil
            if !_alertShown {
                _alertShown = true
                
                let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: "SERVER_UNAVAILABLE".localized(), preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    self._alertShown = false

                    alert.dismiss(animated: true, completion: nil)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
