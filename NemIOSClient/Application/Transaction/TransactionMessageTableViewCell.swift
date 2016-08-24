//
//  TransactionMessageTableViewCell.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

/// All available types for the message table view cell.
enum MessageCellType {
    case Incoming
    case Outgoing
    case Processing
}

/// Represents a message/transaction with a correspondent in the transaction messages view controller.
class TransactionMessageTableViewCell: DetailedTableViewCell {

    // MARK: - Cell Properties
    
    var cellType: MessageCellType!
    var transaction: TransferTransaction! {
        didSet {
            updateCell()
        }
    }
    
    private let transactionDateLabel = UILabel()
    private let transactionMessageTextView = UITextView()
    private let infoTopLabel = UILabel()
    private let infoCenterLabel = UILabel()
    private let infoBottomLabel = UILabel()
    private let incomingColor = UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 234.0/255.0, alpha: 1)
    private let outgoingColor = UIColor(red: 90.0/255.0, green: 179.0/255.0, blue: 232.0/255.0, alpha: 1)
    @IBInspectable var topInset: CGFloat = 2.0
    @IBInspectable var bottomInset: CGFloat = 2.0
    @IBInspectable var leftInset: CGFloat = 5.0
    @IBInspectable var rightInset: CGFloat = 5.0
    
    // MARK: - Cell Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(transactionMessageTextView)
        _contentView?.addSubview(transactionDateLabel)
        _detailedView?.addSubview(infoTopLabel)
        _detailedView?.addSubview(infoCenterLabel)
        _detailedView?.addSubview(infoBottomLabel)
        
        updateCellAppearance()
    }
    
    override func layoutSubviews() {
        
        infoTopLabel.frame.size = CGSize(width: 80, height: 20)
        infoTopLabel.frame.origin = CGPointZero
        infoCenterLabel.frame.size = CGSize(width: 80, height: 20)
        infoCenterLabel.frame.origin = CGPoint(x: 0, y: 20)
        infoBottomLabel.frame.size = CGSize(width: 80, height: 20)
        infoBottomLabel.frame.origin = CGPoint(x: 0, y: 40)
        _detailedView?.frame.size = CGSize(width: 80, height: 60)
        
        super.layoutSubviews()
        
        transactionDateLabel.frame.size.width = _contentView!.frame.width
        transactionDateLabel.sizeToFit()
        transactionDateLabel.frame.size.width = _contentView!.frame.width - 20
        
        switch cellType! {
        case .Incoming :
            transactionDateLabel.frame.origin.x = 20
            transactionMessageTextView.frame.size.width = _contentView!.frame.size.width * 0.75
            transactionMessageTextView.sizeToFit()
            transactionMessageTextView.frame.origin = CGPoint(x: 15, y: transactionDateLabel.frame.height + 5)
            transactionMessageTextView.frame.size = CGSize(width: min(_contentView!.frame.size.width * 0.75, transactionMessageTextView.frame.size.width), height: transactionMessageTextView.frame.size.height)
            
        case .Outgoing :
            transactionDateLabel.frame.origin.x = 0
            transactionMessageTextView.frame.size.width = _contentView!.frame.size.width * 0.75
            transactionMessageTextView.sizeToFit()
            transactionMessageTextView.frame.size = CGSize(width: min(_contentView!.frame.size.width * 0.75, transactionMessageTextView.frame.size.width), height: transactionMessageTextView.frame.size.height)
            transactionMessageTextView.frame.origin = CGPoint(x: _contentView!.frame.size.width - transactionMessageTextView.frame.size.width - 15, y: transactionDateLabel.frame.height + 5)

        case .Processing :
            transactionDateLabel.frame.size.width = _contentView!.frame.width
            transactionMessageTextView.frame.size.width = _contentView!.frame.size.width - CGFloat(30)
            transactionMessageTextView.sizeToFit()
            transactionMessageTextView.frame.size.width = _contentView!.frame.size.width - CGFloat(30)
            transactionMessageTextView.frame.origin = CGPoint(x: 15, y: transactionDateLabel.frame.height + 5)
        }
    }
    
    // MARK: - Cell Helper Methods
    
    /// Updates the table view cell with the provided transaction data.
    private func updateCell() {
        
        var textColor = UIColor.blackColor()
        
        switch cellType! {
        case .Incoming:
            transactionDateLabel.textAlignment = NSTextAlignment.Left
            transactionMessageTextView.backgroundColor = incomingColor
            textColor = UIColor.blackColor()
        case .Outgoing:
            transactionDateLabel.textAlignment = NSTextAlignment.Right
            transactionMessageTextView.backgroundColor = outgoingColor
            textColor = UIColor.whiteColor()
        case .Processing:
            transactionDateLabel.textAlignment = NSTextAlignment.Center
            transactionMessageTextView.backgroundColor = incomingColor
            textColor = UIColor.blackColor()
        }
        
        let message = transaction.message?.message == String() || transaction.message?.message == nil ? "EMPTY_MESSAGE".localized() : transaction.message?.message
        let messageAttributedString = NSMutableAttributedString(string: message!, attributes: [NSForegroundColorAttributeName: textColor, NSFontAttributeName: UIFont.systemFontOfSize(13, weight: UIFontWeightRegular)])
        
        var amount = String()
        if (transaction.amount > 0) {
            
            var symbol = String()
            if transaction.transferType == .Incoming {
                symbol = "+"
            } else {
                symbol = "-"
            }
            
            amount = "\(symbol)\((transaction.amount / 1000000).format()) XEM" ?? String()
            amount = "\n" + amount
            
            let amountAttributedString = NSMutableAttributedString(string: amount, attributes: [NSForegroundColorAttributeName: textColor,NSFontAttributeName: UIFont.systemFontOfSize(15, weight: UIFontWeightMedium)])
            messageAttributedString.appendAttributedString(amountAttributedString)
        }
        
        var date = String()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm dd.MM.yy"
        let timeStamp = Double(transaction.timeStamp)
        date = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: genesis_block_time + timeStamp))
        
        setMessage(messageAttributedString)
        setDate(date)
        
        layoutSubviews()
    }
    
    /// Updates the appearance of the table view cell.
    private func updateCellAppearance() {
        
        transactionDateLabel.numberOfLines = 1
        transactionDateLabel.font = UIFont.systemFontOfSize(10, weight: UIFontWeightRegular)
        
        transactionMessageTextView.scrollEnabled = false
        transactionMessageTextView.layer.cornerRadius = 5
        transactionMessageTextView.clipsToBounds = true
        transactionMessageTextView.editable = false
        transactionMessageTextView.textContainerInset = UIEdgeInsetsMake(8, 5, 8, 5)
        
        infoTopLabel.numberOfLines = 1
        infoTopLabel.font = UIFont(name: "HelveticaNeue-Light", size: 10)
        
        infoCenterLabel.numberOfLines = 1
        infoCenterLabel.font = UIFont(name: "HelveticaNeue-Light", size: 10)
        
        infoBottomLabel.numberOfLines = 1
        infoBottomLabel.font = UIFont(name: "HelveticaNeue-Light", size: 10)
    }
    
    /// Updates the date label with the provided date and calls layoutSubviews.
    private func setDate(date: String) {
        transactionDateLabel.text = date
        layoutSubviews()
    }
    
    /// Updates the message label with the provided message/amount and calls layoutSubviews.
    private func setMessage(message: NSAttributedString) {
        transactionMessageTextView.attributedText = message
        layoutSubviews()
    }
    
    /// Updates the details labels with the provided details.
    private func setDetails(topInformation: NSAttributedString, centerInformation: NSAttributedString, bottomInformation: NSAttributedString) {
        infoTopLabel.attributedText = topInformation
        infoCenterLabel.attributedText = centerInformation
        infoBottomLabel.attributedText = bottomInformation
    }
}
