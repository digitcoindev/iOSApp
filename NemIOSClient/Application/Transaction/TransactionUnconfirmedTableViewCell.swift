//
//  TransactionUnconfirmedTableViewCell.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class TransactionUnconfirmedTableViewCell: UITableViewCell
{
    @IBOutlet weak var fromAccount: UILabel!
    @IBOutlet weak var toAccount: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var xem: UILabel!
    @IBOutlet weak var confirm: UIButton!
    @IBOutlet weak var showChanges: UIButton?
    
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel?
    
    weak var delegate :TransactionUnconfirmedViewController? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        fromLabel.text = "FROM".localized() + ":"
        toLabel.text = "TO".localized() + ":"
        confirm.setTitle("CONFIRM".localized(), for: UIControlState())
        showChanges?.setTitle("SHOW_CHANGES".localized(), for: UIControlState())
        
        fromAccount.text = ""
        toAccount.text = ""
        if message != nil {
            messageLabel?.text = "MESSAGE".localized() + ":"
            message.text = ""
            xem.text = "0 XEM"
        }
        
        confirm.layer.cornerRadius = 5
        showChanges?.layer.cornerRadius = 5
        
        self.layer.cornerRadius = 10
    }

    @IBAction func confirmTouchUpInside(_ sender: AnyObject) {
        self.delegate?.confirmTransactionAtIndex(self.tag)
    }
    @IBAction func showTouchUpInside(_ sender: AnyObject) {
        self.delegate?.showTransactionAtIndex(self.tag)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
