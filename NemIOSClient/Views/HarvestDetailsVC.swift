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
    
    private var _mainAccount :AccountGetMetaData? = nil
    private let _apiManager :APIManager =  APIManager()
    
    private var _blocks :[BlockGetMetaData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToHistoryVC
        State.currentVC = SegueToHistoryVC
        _apiManager.delegate = self
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.currentWallet!.password)
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
        cell.block.text = "Block #\(_blocks[indexPath.row].id)"
        cell.block.text = "Block #\(_blocks[indexPath.row].id)"
        cell.block.text = "Block #\(_blocks[indexPath.row].id)"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, YYYY H:mm:ss"
        
        var timeStamp = Double(_blocks[indexPath.row].timeStamp)
        timeStamp += genesis_block_time
        
        cell.date.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: timeStamp))
        cell.block.text = "Block #\(_blocks[indexPath.row].id)"
        cell.fee.text = "Fee: \(_blocks[indexPath.row].totalFee / 100000)"
        
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
            var message = NSLocalizedString("POI", comment: "Text") + ": " + account!.importance.format(".2") + " ‱"
            var atributedText = NSMutableAttributedString(string: message, attributes: atributes)
            importance.attributedText = atributedText

            message = NSLocalizedString("BALANCE", comment: "Text") + ": "
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
            message = NSLocalizedString("VASTED_BALANCE", comment: "Text") + ": "
            message += (account!.vestedBalance! / 1000000).format(".0") + " XEM"
            atributedText = NSMutableAttributedString(string: message, attributes: atributes)
            vastedBalance.attributedText = atributedText
            
            message = NSLocalizedString("DELEGATED_HARVESTING", comment: "Text") + ": "
            atributedText = NSMutableAttributedString(string: message, attributes: atributes)
            
            message = NSLocalizedString(account!.status, comment: "Text")
            atributes = [
                NSForegroundColorAttributeName : greenClor,
                NSFontAttributeName:fontLight
            ]
            atributedText.appendAttributedString(NSMutableAttributedString(string: message, attributes: atributes))
            harvestingStatus.attributedText = atributedText
            
            if account!.harvestedBlocks > 0 {
                message = String(format: NSLocalizedString("LAST_HARVESTED_BLOCK", comment: "Text"), account!.harvestedBlocks)
                _apiManager.accountHarvests(State.currentServer!, account_address: account!.address)
            } else {
                message = NSLocalizedString("NO_HARVESTED_BLOCK", comment: "Text")
            }
            atributes = [
                NSFontAttributeName:fontLight
            ]
            atributedText = NSMutableAttributedString(string: message, attributes: atributes)
            lastBlocks.attributedText = atributedText
            
            atributes = [
                NSFontAttributeName:fontLight
            ]
            
            let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.currentWallet!.password)
            
            message = "Delegated Key: \(HashManager.SHA256Encrypt(privateKey!.asByteArray()))"
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