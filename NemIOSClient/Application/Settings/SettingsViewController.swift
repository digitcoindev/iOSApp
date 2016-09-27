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
    
    @IBOutlet weak var generalLanguageHeadingLabel: UILabel!
    @IBOutlet weak var generalLanguageValueLabel: UILabel!
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
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller.
    fileprivate func updateViewControllerAppearance() {
        
        title = "SETTINGS".localized()
        generalLanguageHeadingLabel.text = "LANGUAGE".localized()
        generalInvoiceMessageHeadingLabel.text = "INVOICE_MESSAGE_CONFIG".localized()
        generalAboutHeadingLabel.text = "ABOUT".localized()
        securityChangePasswordHeadingLabel.text = "PASSWORD_CHANGE_CONFIG".localized()
        securityTouchIDHeadingLabel.text = "TOUCH_ID".localized()
        serverHeadingLabel.text = "SERVER".localized()
        notificationUpdateIntervalHeadingLabel.text = "UPDATE_INTERVAL".localized()
    }
    
    /**
        Handles displaying informations in the settings view controller.
        For example handles what gets displayed in all detail labels etc.
     */
    fileprivate func handleAllSettings() {
        
        handleApplicationLanguageSetting()
    }
    
    /// Displays the current set application language.
    fileprivate func handleApplicationLanguageSetting() {
        
        let applicationLanguage = SettingsManager.sharedInstance.applicationLanguage()
        
        switch applicationLanguage {
        case .automatic:
            generalLanguageValueLabel.text = "BASE".localized()
        case .german:
            generalLanguageValueLabel.text = "LANGUAGE_GERMAN".localized()
        case .english:
            generalLanguageValueLabel.text = "LANGUAGE_ENGLISH".localized()
        case .spanish:
            generalLanguageValueLabel.text = "LANGUAGE_SPANISH".localized()
        case .finnish:
            generalLanguageValueLabel.text = "LANGUAGE_FINNISH".localized()
        case .french:
            generalLanguageValueLabel.text = "LANGUAGE_FRENCH".localized()
        case .croatian:
            generalLanguageValueLabel.text = "LANGUAGE_CROATIAN".localized()
        case .indonesian:
            generalLanguageValueLabel.text = "LANGUAGE_INDONESIAN".localized()
        case .italian:
            generalLanguageValueLabel.text = "LANGUAGE_ITALIAN".localized()
        case .japanese:
            generalLanguageValueLabel.text = "LANGUAGE_JAPANESE".localized()
        case .korean:
            generalLanguageValueLabel.text = "LANGUAGE_KOREAN".localized()
        case .lithuanian:
            generalLanguageValueLabel.text = "LANGUAGE_LITHUANIAN".localized()
        case .dutch:
            generalLanguageValueLabel.text = "LANGUAGE_DUTCH".localized()
        case .polish:
            generalLanguageValueLabel.text = "LANGUAGE_POLISH".localized()
        case .portuguese:
            generalLanguageValueLabel.text = "LANGUAGE_PORTUGUESE".localized()
        case .chineseSimplified:
            generalLanguageValueLabel.text = "LANGUAGE_CHINESE_SIMPLIFIED".localized()
        }
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
