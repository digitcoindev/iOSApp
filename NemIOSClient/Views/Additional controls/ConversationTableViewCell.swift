//
//  ConversationTableViewCell.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 16.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

enum ConversationCellType: String {
    case Incoming = "Incoming"
    case Outgoing = "Outgoing"
    case Processing = "Processing"
    case Unknown = "Unknown"
}

class ConversationTableViewCell: DetailedTableViewCell {

    // MARK: internal variables
    
    internal let _dateLabel: UILabel? = UILabel()
    internal let _messageLabel: UITextView? = UITextView()
    
    internal let _infoLabelTop: UILabel? = UILabel()
    internal let _infoLabelMiddle: UILabel? = UILabel()
    internal let _infoLabelBottom: UILabel? = UILabel()
    
    internal let _nemColorIncoming = UIColor(red: 142 / 256 , green: 142 / 256, blue: 142 / 256, alpha: 1) // Gray
    internal let _nemColorOutgoing = UIColor(red: 65 / 256 , green: 206 / 256, blue: 123 / 256, alpha: 1) // Green
    
    // MARK: properties
    
    var cellType :ConversationCellType {
        get {
            return _cellType
        }
        
        set {
            _cellType = newValue
            
            switch _cellType {
            case .Incoming :
                _dateLabel?.textAlignment = NSTextAlignment.Left
                _messageLabel?.backgroundColor = _nemColorIncoming
            case .Outgoing :
                _dateLabel?.textAlignment = NSTextAlignment.Right
                _messageLabel?.backgroundColor = _nemColorOutgoing
            case .Processing :
                _dateLabel?.textAlignment = NSTextAlignment.Center
                _messageLabel?.backgroundColor = _nemColorIncoming
            default :
                break
            }
            
            self.layoutSubviews()
        }
    }
    
    // MARK: private variables
    
    private var _cellType :ConversationCellType = ConversationCellType.Unknown
    
    override func awakeFromNib() {
        super.awakeFromNib()

        _dateLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 8)
        _dateLabel?.text = "unrecognized date"
        _dateLabel?.numberOfLines = 1
        self._contentView?.addSubview(_dateLabel!)
        
        _messageLabel?.editable = false
        _messageLabel?.selectable = true
        _messageLabel?.scrollEnabled = false
        _messageLabel?.layer.cornerRadius = 5
        _messageLabel?.clipsToBounds = true
        _messageLabel?.textColor = UIColor.whiteColor()
        self.addSubview(_messageLabel!)
        
        _infoLabelTop?.text = ""
        _infoLabelMiddle?.text = ""
        _infoLabelBottom?.text = ""
        
        _infoLabelTop?.numberOfLines = 1
        _infoLabelTop?.font = UIFont(name: "HelveticaNeue-Light", size: 10)
        _detailedView?.addSubview(_infoLabelTop!)
        
        _infoLabelMiddle?.numberOfLines = 1
        _infoLabelMiddle?.font = UIFont(name: "HelveticaNeue-Light", size: 10)
        _detailedView?.addSubview(_infoLabelMiddle!)
        
        _infoLabelBottom?.numberOfLines = 1
        _infoLabelBottom?.font = UIFont(name: "HelveticaNeue-Light", size: 10)
        _detailedView?.addSubview(_infoLabelBottom!)
    }
    
    // MARK: layout
    
    override func layoutSubviews() {
        
        _infoLabelTop?.frame.size = CGSize(width: 80, height: 20)
        _infoLabelTop?.frame.origin = CGPointZero

        _infoLabelMiddle?.frame.size = CGSize(width: 80, height: 20)
        _infoLabelMiddle?.frame.origin = CGPoint(x: 0, y: 20)

        _infoLabelBottom?.frame.size = CGSize(width: 80, height: 20)
        _infoLabelBottom?.frame.origin = CGPoint(x: 0, y: 40)

        _detailedView?.frame.size = CGSize(width: 80, height: 60)
        
        super.layoutSubviews()
        
        _dateLabel?.frame.size.width = _contentView!.frame.width
        _dateLabel?.sizeToFit()
        _dateLabel?.frame.size.width = _contentView!.frame.width - 20
        
        switch _cellType {
        case .Incoming :
            _dateLabel?.frame.origin.x = 20
            _messageLabel?.frame.size.width = _contentView!.frame.size.width * 0.75
            _messageLabel?.sizeToFit()
            
            _messageLabel?.frame.origin = CGPoint(x: 15, y: _dateLabel!.frame.height)
            _messageLabel?.frame.size = CGSize(width: min(_contentView!.frame.size.width * 0.75, _messageLabel!.frame.size.width), height: _messageLabel!.frame.size.height)
            
        case .Outgoing :
            _dateLabel?.frame.origin.x = 0
            _messageLabel?.frame.size.width = _contentView!.frame.size.width * 0.75
            _messageLabel?.sizeToFit()
            
            _messageLabel?.frame.size = CGSize(width: min(_contentView!.frame.size.width * 0.75, _messageLabel!.frame.size.width), height: _messageLabel!.frame.size.height)
            
            _messageLabel?.frame.origin = CGPoint(x: _contentView!.frame.size.width - _messageLabel!.frame.size.width - 15, y: _dateLabel!.frame.height)

        case .Processing :
            _dateLabel?.frame.size.width = _contentView!.frame.width
            _messageLabel?.frame.size.width = _contentView!.frame.size.width - CGFloat(10)
            _messageLabel?.sizeToFit()
            _messageLabel?.frame.size.width = _contentView!.frame.size.width - CGFloat(10)
            
            _messageLabel?.frame.origin = CGPoint(x: 5, y: _dateLabel!.frame.height)
            
        default :
            break
        }
    }
    
    // MARK: Public Methods

    func setDate(date: String) {
        _dateLabel?.text = date
        layoutSubviews()
    }
    
    func setMessage(message: NSAttributedString) {
        _messageLabel?.attributedText = message
        layoutSubviews()
    }
    
    func setDetails(top: NSAttributedString, middle: NSAttributedString, bottom: NSAttributedString) {
        _infoLabelTop?.attributedText = top
        _infoLabelMiddle?.attributedText = middle
        _infoLabelBottom?.attributedText = bottom
    }
}
