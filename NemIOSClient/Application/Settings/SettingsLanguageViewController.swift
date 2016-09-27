//
//  SettingsLanguageViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

/// The view controller that lets the user change the application language.
class SettingsLanguageViewController: UITableViewController {

    // MARK: - View Controller Properties
    
    fileprivate var applicationLanguage: SettingsManager.ApplicationLanguage?
    fileprivate var applicationLanguageString: String?
    fileprivate let languages: [String] = [
        "BASE".localized(),
        "LANGUAGE_GERMAN".localized(),
        "LANGUAGE_ENGLISH".localized(),
        "LANGUAGE_SPANISH".localized(),
        "LANGUAGE_FINNISH".localized(),
        "LANGUAGE_FRENCH".localized(),
        "LANGUAGE_CROATIAN".localized(),
        "LANGUAGE_INDONESIAN".localized(),
        "LANGUAGE_ITALIAN".localized(),
        "LANGUAGE_JAPANESE".localized(),
        "LANGUAGE_KOREAN".localized(),
        "LANGUAGE_LITHUANIAN".localized(),
        "LANGUAGE_DUTCH".localized(),
        "LANGUAGE_POLISH".localized(),
        "LANGUAGE_PORTUGUESE".localized(),
        "LANGUAGE_CHINESE_SIMPLIFIED".localized()
    ]
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateViewControllerAppearance()
        
        applicationLanguage = SettingsManager.sharedInstance.applicationLanguage()
        
        switch applicationLanguage! {
        case .automatic:
            applicationLanguageString = "BASE".localized()
        case .german:
            applicationLanguageString = "LANGUAGE_GERMAN".localized()
        case .english:
            applicationLanguageString = "LANGUAGE_ENGLISH".localized()
        case .spanish:
            applicationLanguageString = "LANGUAGE_SPANISH".localized()
        case .finnish:
            applicationLanguageString = "LANGUAGE_FINNISH".localized()
        case .french:
            applicationLanguageString = "LANGUAGE_FRENCH".localized()
        case .croatian:
            applicationLanguageString = "LANGUAGE_CROATIAN".localized()
        case .indonesian:
            applicationLanguageString = "LANGUAGE_INDONESIAN".localized()
        case .italian:
            applicationLanguageString = "LANGUAGE_ITALIAN".localized()
        case .japanese:
            applicationLanguageString = "LANGUAGE_JAPANESE".localized()
        case .korean:
            applicationLanguageString = "LANGUAGE_KOREAN".localized()
        case .lithuanian:
            applicationLanguageString = "LANGUAGE_LITHUANIAN".localized()
        case .dutch:
            applicationLanguageString = "LANGUAGE_DUTCH".localized()
        case .polish:
            applicationLanguageString = "LANGUAGE_POLISH".localized()
        case .portuguese:
            applicationLanguageString = "LANGUAGE_PORTUGUESE".localized()
        case .chineseSimplified:
            applicationLanguageString = "LANGUAGE_CHINESE_SIMPLIFIED".localized()
        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "SettingsOptionTableViewCell") as! SettingsOptionTableViewCell
        cell.title = languages[indexPath.row]

        if languages[indexPath.row] == applicationLanguageString {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let applicationLanguageString = languages[indexPath.row]
        var applicationLanguage = SettingsManager.ApplicationLanguage.automatic
        
        switch applicationLanguageString {
        case "BASE".localized():
            applicationLanguage = .automatic
        case "LANGUAGE_GERMAN".localized():
            applicationLanguage = .german
        case "LANGUAGE_ENGLISH".localized():
            applicationLanguage = .english
        case "LANGUAGE_SPANISH".localized():
            applicationLanguage = .spanish
        case "LANGUAGE_FINNISH".localized():
            applicationLanguage = .finnish
        case "LANGUAGE_FRENCH".localized():
            applicationLanguage = .french
        case "LANGUAGE_CROATIAN".localized():
            applicationLanguage = .croatian
        case "LANGUAGE_INDONESIAN".localized():
            applicationLanguage = .indonesian
        case "LANGUAGE_ITALIAN".localized():
            applicationLanguage = .italian
        case "LANGUAGE_JAPANESE".localized():
            applicationLanguage = .japanese
        case "LANGUAGE_KOREAN".localized():
            applicationLanguage = .korean
        case "LANGUAGE_LITHUANIAN".localized():
            applicationLanguage = .lithuanian
        case "LANGUAGE_DUTCH".localized():
            applicationLanguage = .dutch
        case "LANGUAGE_POLISH".localized():
            applicationLanguage = .polish
        case "LANGUAGE_PORTUGUESE".localized():
            applicationLanguage = .portuguese
        case "LANGUAGE_CHINESE_SIMPLIFIED".localized():
            applicationLanguage = .chineseSimplified
        default:
            applicationLanguage = .automatic
        }
        
        SettingsManager.sharedInstance.setApplicationLanguage(applicationLanguage: applicationLanguage)
        self.applicationLanguage = applicationLanguage
        self.applicationLanguageString = applicationLanguageString
        tableView.reloadData()
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller.
    fileprivate func updateViewControllerAppearance() {
        
        title = "LANGUAGE".localized()
    }
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        
        navigationController?.popViewController(animated: true)
    }
}
