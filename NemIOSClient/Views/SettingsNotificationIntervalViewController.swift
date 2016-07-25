//
//  ChouseUpdateInterval.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 13.01.16.
//  Copyright © 2016 Artygeek. All rights reserved.
//

import UIKit

class SettingsNotificationIntervalViewController: AbstractViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - @IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var resetButton: UIButton!
    
    private let _intervals :[Int] = [0, 90, 180, 360, 720, 1440, 2880, 4320, 8640]
    
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
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)

        let loadData = State.loadData
        loadData?.updateInterval = 0
        CoreDataManager().commit()
        (self.delegate as! AbstractViewController).viewDidAppear(false)
        closePopUp(self)
    }
    
    // MARK: - TableViewDelegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _intervals.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : ActiveCell = self.tableView.dequeueReusableCellWithIdentifier("acc cell") as! ActiveCell
        switch _intervals[indexPath.row] {
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
        
        if _intervals[indexPath.row] == State.loadData?.updateInterval as! Int {
            cell.isActive = true
        } else {
            cell.isActive = false
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
        } else {
            UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(NSTimeInterval(_intervals[indexPath.row]))
        }

        let loadData = State.loadData
        loadData?.updateInterval = _intervals[indexPath.row]
        CoreDataManager().commit()
        (self.delegate as! AbstractViewController).viewDidAppear(false)
        closePopUp(self)
    }
}
