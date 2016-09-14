//
//  ServerViewCell.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

@objc protocol ServerCellDelegate
{
    @objc optional func deleteCell(_ cell :UITableViewCell)
}

class ServerViewCell: UITableViewCell
{
    @IBOutlet weak var serverName: UILabel!
    @IBOutlet weak var editingView: UIView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var actionContent: UIView!
    
    fileprivate var _inEditingState :Bool = false
    fileprivate var _isActiveServer :Bool = false
    
    
    var isActiveServer :Bool {
        get {
            return _isActiveServer
        }
        set {
            _isActiveServer = newValue
        }
    }
    
    var inEditingState :Bool {
        get {
            return _inEditingState
        }
        set {
            _inEditingState = newValue
        }
    }
    
    weak var delegate :AnyObject? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        _inEditingState = false
        self.contentView.clipsToBounds = true
    }
    
    final func layoutCell(animated :Bool) {
        let duration = (animated) ? 0.5 : 0.1
        if !_inEditingState {
            
            let cons: NSLayoutConstraint? = self.contentView.constraints.first!
            cons?.constant = -58
            
            
            UIView.animate(withDuration: duration, animations: { () -> Void in
                self.contentView.layoutIfNeeded()
                }, completion: { (successed :Bool) -> Void in
                    if self._isActiveServer {
                        self.actionButton.setImage(UIImage(named: "server_indicator_active"), for: UIControlState())
                    } else {
                        self.actionButton.setImage(UIImage(named: "server_indicator_passive"), for: UIControlState())
                    }
                    
            })
        } else {
            
            let cons: NSLayoutConstraint? = self.contentView.constraints.first
            cons?.constant = 0
            
            
            UIView.animate(withDuration: duration, animations: { () -> Void in
                self.contentView.layoutIfNeeded()
                }, completion: { (successed :Bool) -> Void in
                    
                    self.actionButton.setImage(UIImage(named: "delete_icon"), for: UIControlState())
            })
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    @IBAction func deleteCell(_ sender: AnyObject){
        
        if _inEditingState {
            if self.delegate != nil && self.delegate!.responds(to: #selector(ServerCellDelegate.deleteCell(_:))) {
                (self.delegate as! ServerCellDelegate).deleteCell!(self)
            }
        } else {
            super.setSelected(true, animated: true)
        }
    }
}
