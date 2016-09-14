//
//  SettingsNotificationIntervalViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class SettingsNotificationIntervalViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - @IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var resetButton: UIButton!
    
    fileprivate let _intervals :[Int] = [0, 90, 180, 360, 720, 1440, 2880, 4320, 8640]
    
    //MARK: - Load Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        
        resetButton.setTitle("RESET".localized(), for: UIControlState())
        
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 10)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - @IBAction
    
    @IBAction func closePopUp(_ sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func reset(_ sender: AnyObject) {
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)

        let loadData = State.loadData
        loadData?.updateInterval = 0
//        CoreDataManager().commit()
//        (self.delegate as! AbstractViewController).viewDidAppear(false)
        closePopUp(self)
    }
    
    // MARK: - TableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _intervals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ActiveCell = self.tableView.dequeueReusableCell(withIdentifier: "acc cell") as! ActiveCell
        switch _intervals[(indexPath as NSIndexPath).row] {
        case 0 :
            cell.title.text = "NEVER".localized()
        case 90 :
            cell.title.text = "30 " + "MINUTES".localized()
        case 180 :
            cell.title.text = "60 " + "MINUTES".localized()
        case 360 :
            cell.title.text = "1 " + "HOURS".localized()
        case 720 :
            cell.title.text = "2 " + "HOURS".localized()
        case 1440 :
            cell.title.text = "4 " + "HOURS".localized()
        case 2880 :
            cell.title.text = "8 " + "HOURS".localized()
        case 4320 :
            cell.title.text = "12 " + "HOURS".localized()
        case 8640 :
            cell.title.text = "24 " + "HOURS".localized()
        default :
            break
        }
        
        if _intervals[(indexPath as NSIndexPath).row] == State.loadData?.updateInterval as! Int {
            cell.isActive = true
        } else {
            cell.isActive = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0 {
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
        } else {
            UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(_intervals[(indexPath as NSIndexPath).row]))
        }

        let loadData = State.loadData
        loadData?.updateInterval = _intervals[(indexPath as NSIndexPath).row] as NSNumber?
//        CoreDataManager().commit()
//        (self.delegate as! AbstractViewController).viewDidAppear(false)
        closePopUp(self)
    }
}
