//
//  HarvestDetailsVC.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 28.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class HarvestDetailsVC: AbstractViewController , UITableViewDelegate, APIManagerDelegate {
    
    @IBOutlet weak var importance: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var vastedBalance: UILabel!
    @IBOutlet weak var harvestingStatus: UILabel!
    @IBOutlet weak var delegatedKey: UILabel!
    @IBOutlet weak var lastBlocks: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var titleLabel: UILabel!

    private var _mainAccount :AccountGetMetaData? = nil
    private let _apiManager :APIManager =  APIManager()
    
    private var _blocks :[BlockGetMetaData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.currentVC = SegueToHistoryVC
        _apiManager.delegate = self
        
        titleLabel.text = "HARVEST_DETAILS".localized()
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
        let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey!)
        
        _apiManager.accountGet(State.currentServer!, account_address: account_address)
    }
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToMainMenu)
        }
    }
    //MARK: - UITableViewDelegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _blocks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell :BlockTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("block cell") as! BlockTableViewCell
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, YYYY H:mm:ss"
        
        var timeStamp = Double(_blocks[indexPath.row].timeStamp)
        timeStamp += genesis_block_time
        
        cell.date.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: timeStamp))
        cell.block.text = "BLOCK".localized() + " #\(_blocks[indexPath.row].id)"
        cell.fee.text = "FEE".localized() + ": \(_blocks[indexPath.row].totalFee / 100000)"
        
        return cell
    }
    
    //MARK: - APIManagerDelegate Methods
    
    func accountGetResponceWithAccount(account: AccountGetMetaData?) {
        
        if account != nil {
            
            _mainAccount = account
            
            let fontLight = UIFont(name: "HelveticaNeue-Light", size: 16)!
            let greenClor = UIColor(red: 51 / 256, green: 191 / 256, blue: 86 / 256, alpha: 1)
            
            var atributes :[String:AnyObject] = [
                NSFontAttributeName : fontLight
            ]
            var message = "POI".localized() + ": " + account!.importance.format(".2") + " ‱"
            var atributedText = NSMutableAttributedString(string: message, attributes: atributes)
            importance.attributedText = atributedText

            message = "BALANCE".localized() + ": "
            atributedText = NSMutableAttributedString(string: message, attributes: atributes)
            
            atributes = [
                NSForegroundColorAttributeName : greenClor,
                NSFontAttributeName:fontLight
            ]
            message = "\(account!.balance / 1000000)" + " XEM"
            atributedText.appendAttributedString(NSMutableAttributedString(string: message, attributes: atributes))
            
            balance.attributedText = atributedText
            
            atributes = [
                NSFontAttributeName:fontLight
            ]
            message = "VASTED_BALANCE".localized() + ": "
            message += (account!.vestedBalance! / 1000000).format(".0") + " XEM"
            atributedText = NSMutableAttributedString(string: message, attributes: atributes)
            vastedBalance.attributedText = atributedText
            
            message = "DELEGATED_HARVESTING".localized() + ": "
            atributedText = NSMutableAttributedString(string: message, attributes: atributes)
            
            message = account!.status.localized()
            atributes = [
                NSForegroundColorAttributeName : greenClor,
                NSFontAttributeName:fontLight
            ]
            atributedText.appendAttributedString(NSMutableAttributedString(string: message, attributes: atributes))
            harvestingStatus.attributedText = atributedText
            
            if account!.harvestedBlocks > 0 {
                message = String(format: "LAST_HARVESTED_BLOCK".localized(), (account!.harvestedBlocks > 25) ? 25 : account!.harvestedBlocks)
                _apiManager.accountHarvests(State.currentServer!, account_address: account!.address)
            } else {
                message = "NO_HARVESTED_BLOCK".localized()
            }
            atributes = [
                NSFontAttributeName:fontLight
            ]
            atributedText = NSMutableAttributedString(string: message, attributes: atributes)
            lastBlocks.attributedText = atributedText
            
            atributes = [
                NSFontAttributeName:fontLight
            ]
            
            let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
            
            message = "DELEGATED_KEY".localized() + ": \(HashManager.SHA256Encrypt(privateKey!.asByteArray()))"
            atributedText = NSMutableAttributedString(string: message, attributes: atributes)
            
            atributes = [
                NSForegroundColorAttributeName : greenClor,
                NSFontAttributeName:fontLight
            ]
            delegatedKey.attributedText = atributedText
        }
    }
    
    func accountHarvestResponceWithBlocks(blocks: [BlockGetMetaData]?) {
        if blocks != nil && blocks!.count > 0 {
            _blocks = blocks!
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
}