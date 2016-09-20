//
//  HarvestingViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class HarvestingViewController: UIViewController , UITableViewDelegate, APIManagerDelegate {
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var importance: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var vastedBalance: UILabel!
    @IBOutlet weak var harvestingStatus: UILabel!
    @IBOutlet weak var delegatedKey: UITextView!
    @IBOutlet weak var lastBlocks: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var _mainAccount :AccountGetMetaData? = nil
    fileprivate let _apiManager :APIManager =  APIManager()
    
    fileprivate var _blocks :[BlockGetMetaData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _apiManager.delegate = self
        
        title = "HARVEST_DETAILS".localized()
        
        let privateKey = HashManager.AES256Decrypt(inputText: State.currentWallet!.privateKey, key: State.loadData!.password!)
        let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey!)
        
        _apiManager.accountGet(State.currentServer!, account_address: account_address)
        infoView.clipsToBounds = true
        infoView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        State.currentVC = SegueToHistoryVC
    }

    //MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _blocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell :HarvestingBlockTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "block cell") as! HarvestingBlockTableViewCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, YYYY H:mm:ss"
        
        var timeStamp = Double(_blocks[(indexPath as NSIndexPath).row].timeStamp)
        timeStamp += genesis_block_time
        
        cell.date.text = dateFormatter.string(from: Date(timeIntervalSince1970: timeStamp))
        cell.block.text = "BLOCK".localized() + " #\(_blocks[(indexPath as NSIndexPath).row].id)"
        cell.fee.text = "FEE".localized() + ": \(_blocks[(indexPath as NSIndexPath).row].totalFee / 100000)"
        
        return cell
    }
    
    //MARK: - APIManagerDelegate Methods
    
    func accountGetResponceWithAccount(_ account: AccountGetMetaData?) {
        
        if account != nil {
            
            _mainAccount = account
            
            let fontLight = UIFont(name: "HelveticaNeue-Light", size: 14)!
            let greenClor = UIColor(red: 51 / 256, green: 191 / 256, blue: 86 / 256, alpha: 1)
            
            var atributes :[String:AnyObject] = [
                NSFontAttributeName : fontLight
            ]
            var message = "POI".localized() + ": " + account!.importance.format(maximumFractionDigits: 2) + " ‱"
            var atributedText = NSMutableAttributedString(string: message, attributes: atributes)
            importance.attributedText = atributedText

            message = "BALANCE".localized() + ": "
            atributedText = NSMutableAttributedString(string: message, attributes: atributes)
            
            atributes = [
                NSForegroundColorAttributeName : greenClor,
                NSFontAttributeName:fontLight
            ]
            message = "\(account!.balance / 1000000)" + " XEM"
            atributedText.append(NSMutableAttributedString(string: message, attributes: atributes))
            
            balance.attributedText = atributedText
            
            atributes = [
                NSFontAttributeName:fontLight
            ]
            message = "VASTED_BALANCE".localized() + ": "
            message += (account!.vestedBalance! / 1000000).format() + " XEM"
            atributedText = NSMutableAttributedString(string: message, attributes: atributes)
            vastedBalance.attributedText = atributedText
            
            message = "DELEGATED_HARVESTING".localized() + ": "
            atributedText = NSMutableAttributedString(string: message, attributes: atributes)
            
            switch account!.remoteStatus {
            case "ACTIVE" :
                message = "UNLOCKED".localized()
            default :
                message = "LOCKED".localized()
            }
            atributes = [
                NSForegroundColorAttributeName : greenClor,
                NSFontAttributeName:fontLight
            ]
            atributedText.append(NSMutableAttributedString(string: message, attributes: atributes))
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
            
            let privateKey = HashManager.AES256Decrypt(inputText: State.currentWallet!.privateKey, key: State.loadData!.password!)
            
            message = "DELEGATED_KEY".localized() + ": \(HashManager.SHA256Encrypt(privateKey!.asByteArray()))"
            atributedText = NSMutableAttributedString(string: message, attributes: atributes)
            delegatedKey.attributedText = atributedText
            
            if account!.status == "LOCKED" {
                for constraint in infoView.constraints {
                    if constraint.identifier == "InfoHeight" {
                        constraint.constant = 155
                    }
                }
                delegatedKey.isHidden = true
            }
            
            infoView.isHidden = false
        }
    }
    
    func accountHarvestResponceWithBlocks(_ blocks: [BlockGetMetaData]?) {
        if blocks != nil && blocks!.count > 0 {
            _blocks = blocks!
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
}
