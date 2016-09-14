//
//  SettingsDefaultAccountViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class SettingsDefaultAccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - @IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var resetButton: UIButton!
    
//    private let _accounts :[Wallet] = CoreDataManager().getWallets()
    
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
        let loadData = State.loadData
        loadData?.currentWallet = nil
//        CoreDataManager().commit()
//        (self.delegate as! AbstractViewController).viewDidAppear(false)
        closePopUp(self)
    }
    
    // MARK: - TableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return _accounts.count
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ActiveCell = self.tableView.dequeueReusableCell(withIdentifier: "acc cell") as! ActiveCell

//        cell.title.text = _accounts[indexPath.row].login
//        if (_accounts[indexPath.row].privateKey == State.loadData?.currentWallet?.privateKey) && (_accounts[indexPath.row].login == State.loadData?.currentWallet?.login) {
//            cell.isActive = true
//        } else {
//            cell.isActive = false
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let loadData = State.loadData
//        loadData?.currentWallet = _accounts[indexPath.row]
//        CoreDataManager().commit()
//        (self.delegate as! AbstractViewController).viewDidAppear(false)
        closePopUp(self)
    }
}
