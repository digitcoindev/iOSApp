//
//  SettingsViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

/// The view controller that lets the user perform settings changes.
class SettingsViewController: UITableViewController {
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var generalInvoiceMessageHeadingLabel: UILabel!
    @IBOutlet weak var generalAboutHeadingLabel: UILabel!
    @IBOutlet weak var securityChangePasswordHeadingLabel: UILabel!
    @IBOutlet weak var securityTouchIDHeadingLabel: UILabel!
    @IBOutlet weak var securityTouchIDValueLabel: UILabel!
    @IBOutlet weak var serverHeadingLabel: UILabel!
    @IBOutlet weak var serverValueLabel: UILabel!
    @IBOutlet weak var notificationUpdateIntervalHeadingLabel: UILabel!
    @IBOutlet weak var notificationUpdateIntervalValueLabel: UILabel!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViewControllerAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (tableView.indexPathForSelectedRow != nil) {
            let path = tableView.indexPathForSelectedRow!
            tableView.deselectRow(at: path, animated: true)
        }
        
        handleAllSettings()
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return "GENERAL".localized()
        case 1:
            return "SECURITY".localized()
        case 2:
            return "SERVER_SETTINGS".localized()
        case 3:
            return "NOTIFICATION".localized()
        default:
            return String()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            
            switch indexPath.row {
            case 1:
                
                let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
                let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String

                showAlert(withMessage: "\("VERSION".localized()) \(versionNumber) \("BUILD".localized()) \(buildNumber) BETA")
                tableView.deselectRow(at: indexPath, animated: true)
                
            default:
                break
            }
            
        case 1:
            
            switch indexPath.row {
            case 1:
                
                var authenticationTouchIDStatus = SettingsManager.sharedInstance.authenticationTouchIDStatus()
                authenticationTouchIDStatus = !authenticationTouchIDStatus
                
                SettingsManager.sharedInstance.setAuthenticationTouchIDStatus(authenticationTouchIDStatus: authenticationTouchIDStatus)
                
                handleAuthenticationTouchIDSetting()
                tableView.deselectRow(at: indexPath, animated: true)
                
            default:
                break
            }
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller.
    fileprivate func updateViewControllerAppearance() {
        
        title = "SETTINGS".localized()
        generalInvoiceMessageHeadingLabel.text = "INVOICE_MESSAGE_CONFIG".localized()
        generalAboutHeadingLabel.text = "ABOUT".localized()
        securityChangePasswordHeadingLabel.text = "PASSWORD_CHANGE_CONFIG".localized()
        securityTouchIDHeadingLabel.text = "TOUCH_ID".localized()
        serverHeadingLabel.text = "SERVER".localized()
        notificationUpdateIntervalHeadingLabel.text = "UPDATE_INTERVAL".localized()
    }
    
    /**
        Shows an alert view controller with the provided alert message.
     
        - Parameter message: The message that should get shown.
        - Parameter completion: An optional action that should get performed on completion.
     */
    fileprivate func showAlert(withMessage message: String, completion: ((Void) -> Void)? = nil) {
        
        let alert = UIAlertController(title: "INFO".localized(), message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
            completion?()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    /**
        Handles displaying informations in the settings view controller.
        For example handles what gets displayed in all detail labels etc.
     */
    fileprivate func handleAllSettings() {
        
        handleAuthenticationTouchIDSetting()
        handleActiveServerSetting()
    }
    
    /// Displays the current touch id setting status.
    fileprivate func handleAuthenticationTouchIDSetting() {

        let authenticationTouchIDStatus = SettingsManager.sharedInstance.authenticationTouchIDStatus()
        
        securityTouchIDValueLabel.text = authenticationTouchIDStatus ? "ON".localized() : "OFF".localized()
    }
    
    /// Displays the currently active server.
    fileprivate func handleActiveServerSetting() {
        
        let activeServer = SettingsManager.sharedInstance.activeServer()
        
        serverValueLabel.text = activeServer.address
    }
    
    fileprivate final func _refreshData(){
//        var serverText = ""
//        if let server = _loadData?.currentServer {
//            serverText = server.address
//        } else {
//            serverText = "NONE".localized()
//        }
//        
//        let accountText = ""
////        if let account = _loadData?.currentWallet {
////            accountText = account.login
////        } else if _dataManager.getWallets().count == 0 {
////            accountText = "NO_ACCOUNTS".localized()
////        } else {
////            accountText = "NONE".localized()
////        }
//        
//        var touchText = ""
//        
//        if (_loadData?.touchId ?? true) as Bool {
//            touchText = "ON".localized()
//        } else {
//            touchText = "OFF".localized()
//        }
//        
//        var updateInterval = ""
//        
//        switch Int(_loadData!.updateInterval!) {
//        case 0 :
//            updateInterval = "NEVER".localized()
//        case 90 :
//            updateInterval = "30 " + "MINUTES".localized()
//        case 180 :
//            updateInterval = "60 " + "MINUTES".localized()
//        case 360 :
//            updateInterval = "1 " + "HOURS".localized()
//        case 720 :
//            updateInterval = "2 " + "HOURS".localized()
//        case 1440 :
//            updateInterval = "4 " + "HOURS".localized()
//        case 2880 :
//            updateInterval = "8 " + "HOURS".localized()
//        case 4320 :
//            updateInterval = "12 " + "HOURS".localized()
//        case 8640 :
//            updateInterval = "24 " + "HOURS".localized()
//        default :
//            break
//        }
//        
//        _content = []
//        _content += [
//            [
//                ["GENERAL".localized()],
//                ["LANGUAGE".localized(), _loadData?.currentLanguage ?? "BASE".localized()],
//                ["ACCOUNT_PRIMATY".localized("Primary Account"), accountText],
//                ["INVOICE_MESSAGE_CONFIG".localized(), "SET_CONFIGURATION".localized()],
//                ["ABOUT".localized(), ""]
//            ],
//            [
//                ["SECURITY".localized()],
//                ["PASSWORD_CHANGE_CONFIG".localized() ,"CHANGE".localized()],
//                ["TOUCH_ID".localized() ,touchText]
//            ],
//            [
//                ["SERVER_SETTINGS".localized()],
//                ["SERVER".localized() ,serverText]
//            ],
//            [
//                ["NOTIFICATION".localized()],
//                ["UPDATE_INTERVAL".localized() ,updateInterval]
//            ]
//        ]
//        
//        tableView.reloadData()
    }
}
