//
//  SettingsViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIManagerDelegate
{
    private enum SettingsCategory :Int {
        case General = 0
        case Security = 1
        case Server = 2
        case Notification = 3
    }
    
//    let dataManager :CoreDataManager = CoreDataManager()
    
    @IBOutlet weak var tableView: UITableView!
    
    private var _content :[[[String]]] = []
    private var _loadData :LoadData? = State.loadData
    private var _popUp :UIViewController? = nil
//    private let _dataManager = CoreDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        
        _refreshData()
    }
    
    override func viewDidAppear(animated: Bool) {
        _refreshData()
//        State.currentVC = SegueToSettings
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return max(_content.count, 1)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if _content.count == 0 {return 1}
        return max(_content[section].count, 1)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if _content.count == 0 {
            return self.tableView!.dequeueReusableCellWithIdentifier("Loading")!
        }
        
        var cell :ProfileTableViewCell!

        if indexPath.row == 0 {
            cell = self.tableView!.dequeueReusableCellWithIdentifier("category cell") as! ProfileTableViewCell

        } else {
            cell = self.tableView!.dequeueReusableCellWithIdentifier("content cell") as! ProfileTableViewCell
        }
        
        
        cell.titleLabel!.text = _content[indexPath.section][indexPath.row][0]
        cell.contentLabel?.text = _content[indexPath.section][indexPath.row][1]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case SettingsCategory.General.rawValue :
            switch indexPath.row {
            case 1:
                _createPopUp("SettingsLanguageViewController")
            case 2: break
//                if _dataManager.getWallets().count != 0 {
//                    _createPopUp("SettingsDefaultAccountViewController")
//                }
                
            case 3:
                _createPopUp("SettingsInvoiceViewController")
                
            case 4:
                
                _createPopUp("SettingsAboutViewController")
                
            default:
                break
            }
        case SettingsCategory.Server.rawValue:
            switch indexPath.row {
            case 1:
                performSegueWithIdentifier("showSettingsServerViewController", sender: nil)
            default:
                break
            }
            
        case SettingsCategory.Security.rawValue:
            switch indexPath.row {
            case 1:
                _createPopUp("SettingsChangePasswordViewController")
                break
                
            case 2:
                if (_loadData!.touchId ?? true) as Bool {
                    _loadData!.touchId = false
                } else {
                    _loadData!.touchId = true
                }
                
//                dataManager.commit()
                
                _refreshData()
            default:
                break
            }
            
        case SettingsCategory.Notification.rawValue:
            switch indexPath.row {
            case 1:
                _createPopUp("SettingsNotificationIntervalViewController")
                break

            default:
                break
            }
        default:
            break
        }
    }
    
    //MARK: - Private Methods
    
    private final func _refreshData(){
        _loadData = State.loadData
        title = "SETTINGS".localized()
        var serverText = ""
        if let server = _loadData?.currentServer {
            serverText = server.address
        } else {
            serverText = "NONE".localized()
        }
        
        var accountText = ""
//        if let account = _loadData?.currentWallet {
//            accountText = account.login
//        } else if _dataManager.getWallets().count == 0 {
//            accountText = "NO_ACCOUNTS".localized()
//        } else {
//            accountText = "NONE".localized()
//        }
        
        var touchText = ""
        
        if (_loadData?.touchId ?? true) as Bool {
            touchText = "ON".localized()
        } else {
            touchText = "OFF".localized()
        }
        
        var updateInterval = ""
        
        switch Int(_loadData!.updateInterval!) {
        case 0 :
            updateInterval = "NEVER".localized()
        case 90 :
            updateInterval = "30 " + "MINUTES".localized()
        case 180 :
            updateInterval = "60 " + "MINUTES".localized()
        case 360 :
            updateInterval = "1 " + "HOURS".localized()
        case 720 :
            updateInterval = "2 " + "HOURS".localized()
        case 1440 :
            updateInterval = "4 " + "HOURS".localized()
        case 2880 :
            updateInterval = "8 " + "HOURS".localized()
        case 4320 :
            updateInterval = "12 " + "HOURS".localized()
        case 8640 :
            updateInterval = "24 " + "HOURS".localized()
        default :
            break
        }
        
        _content = []
        _content += [
            [
                ["GENERAL".localized()],
                ["LANGUAGE".localized(), _loadData?.currentLanguage ?? "BASE".localized()],
                ["ACCOUNT_PRIMATY".localized("Primary Account"), accountText],
                ["INVOICE_MESSAGE_CONFIG".localized(), "SET_CONFIGURATION".localized()],
                ["ABOUT".localized(), ""]
            ],
            [
                ["SECURITY".localized()],
                ["PASSWORD_CHANGE_CONFIG".localized() ,"CHANGE".localized()],
                ["TOUCH_ID".localized() ,touchText]
            ],
            [
                ["SERVER_SETTINGS".localized()],
                ["SERVER".localized() ,serverText]
            ],
            [
                ["NOTIFICATION".localized()],
                ["UPDATE_INTERVAL".localized() ,updateInterval]
            ]
        ]
        
        tableView.reloadData()
    }
    
    private final func _createPopUp(withId: String) {
        if _popUp != nil {
            _popUp!.view.removeFromSuperview()
            _popUp!.removeFromParentViewController()
            _popUp = nil
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let popUpController :UIViewController =  storyboard.instantiateViewControllerWithIdentifier(withId) as! UIViewController
        popUpController.view.frame = CGRect(x: 0, y: view.frame.height, width: popUpController.view.frame.width, height: popUpController.view.frame.height - view.frame.height)
        popUpController.view.layer.opacity = 0
//        popUpController.delegate = self
        
        _popUp = popUpController
        self.view.addSubview(popUpController.view)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            popUpController.view.layer.opacity = 1
            }, completion: nil)

    }
}
