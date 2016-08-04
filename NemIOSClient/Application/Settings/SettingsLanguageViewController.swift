//
//  SettingsLanguageViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class SettingsLanguageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - @IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var resetButton: UIButton!
    
    private let _languages :[String] =
        [   "LANGUAGE_GERMAN".localized(),
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
            "LANGUAGE_CHINESE_SIMPLIFIED".localized(),
            "Debug"]
    
    //MARK: - Load Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        
        resetButton.setTitle("RESET".localized(), forState: UIControlState.Normal)
        
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 10)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - @IBAction
    
    @IBAction func closePopUp(sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func reset(sender: AnyObject) {
        LocalizationManager.setLanguage("Default")

        let loadData = State.loadData
        loadData?.currentLanguage = nil
//        CoreDataManager().commit()
//        (self.delegate as! AbstractViewController).viewDidAppear(false)
        closePopUp(self)
    }
    
    // MARK: - TableViewDelegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _languages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : ActiveCell = self.tableView.dequeueReusableCellWithIdentifier("acc cell") as! ActiveCell
        
        cell.title.text = _languages[indexPath.row]
        if _languages[indexPath.row] == State.loadData?.currentLanguage {
            cell.isActive = true
        } else {
            cell.isActive = false
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {        
        
        LocalizationManager.setLanguage(_languages[indexPath.row])
        let loadData = State.loadData
        loadData?.currentLanguage = _languages[indexPath.row]
//        CoreDataManager().commit()
//        (self.delegate as! AbstractViewController).viewDidAppear(false)
        closePopUp(self)
    }
}
