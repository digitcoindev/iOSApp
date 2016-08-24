//
//  TransactionOverviewCorrespondentTableViewCell.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

/**
    The table view cell that represents a correspondent in the
    transaction overview table view controller.
 */
class TransactionOverviewCorrespondentTableViewCell: UITableViewCell {
    
    // MARK: - Cell Properties
    
    var account: Account?
    var correspondent: Correspondent? {
        didSet {
            updateCell()
        }
    }
    
    // MARK: - Cell Outlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mostRecentMessageLabel: UILabel!
    @IBOutlet weak var mostRecentDateLabel: UILabel!
    @IBOutlet weak var mostRecentAmountLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Cell Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateCellAppearance()
    }

    // MARK: - Cell Helper Methods
    
    /// Updates the table view cell with the provided correspondent data.
    private func updateCell() {
        
        nameLabel.text = correspondent!.name != nil ? correspondent!.name : correspondent!.accountAddress.nemAddressNormalised()
        mostRecentMessageLabel.text = correspondent!.mostRecentTransaction.message?.message ?? String()
        mostRecentDateLabel.text = getDate(fromTransactionTimeStamp: correspondent!.mostRecentTransaction.timeStamp)
        mostRecentAmountLabel.attributedText = formatAmount(correspondent!.mostRecentTransaction.amount)
    }
    
    /// Updates the appearance of the table view cell.
    private func updateCellAppearance() {
        
        containerView.layer.cornerRadius = 5
    }
    
    /**
        Converts the given transaction time stamp to a human readable date string.
        If the transaction was performed today, the time of the transaction gets returned.
     
        - Parameter timeStampe: The transaction time stamp that should get converted.
     
        - Returns: The human readable date or time the transaction was performed as a string.
     */
    private func getDate(fromTransactionTimeStamp timeStamp: Int) -> String {
        
        let timeStamp = Double(timeStamp) + genesis_block_time
        var date = String()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: timeStamp)) == dateFormatter.stringFromDate(NSDate()) {
            dateFormatter.dateFormat = "HH:mm"
        }
        
        if correspondent!.mostRecentTransaction.metaData!.id != nil {
            date = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: timeStamp))
        } else {
            date = "UNCONFIRMED_DASHBOARD".localized()
        }
        
        return date
    }
    
    /**
        Creates an attributed string of the amount with coloring that indicates
        if the transaction was an incoming or an outgoing transaction and more.
     
        - Parameter amount: The transaction amount which should get turned into an formatted attributed string.
     
        - Returns: The amount as a formatted attributed string.
     */
    private func formatAmount(amount: Double) -> NSMutableAttributedString {
        
        var amountAttributedString = NSMutableAttributedString()
        var textColor = UIColor()
        var sign = String()
        
        if (correspondent!.mostRecentTransaction.transferType == .Outgoing && correspondent!.mostRecentTransaction.recipient != account!.address) {
            sign = "-"
            textColor = UIColor.redColor()
        } else if correspondent!.mostRecentTransaction.signer == account!.publicKey {
            sign = "±"
            textColor = UIColor(red: 142.0/255.0, green: 142.0/255.0, blue: 142.0/255.0, alpha: 1)
        } else {
            sign = "+"
            textColor = UIColor(red: 65.0/255.0, green: 206.0/255.0, blue: 123.0/255.0, alpha: 1)
        }
        
        amountAttributedString = NSMutableAttributedString(string: "\(sign)\((amount / 1000000).format()) XEM", attributes: [NSForegroundColorAttributeName: textColor])
        
        return amountAttributedString
    }
}
