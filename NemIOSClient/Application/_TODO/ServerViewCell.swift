//
//  ServerViewCell.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

@objc protocol ServerCellDelegate
{
    optional func deleteCell(cell :UITableViewCell)
}

class ServerViewCell: UITableViewCell
{
    @IBOutlet weak var serverName: UILabel!
    @IBOutlet weak var editingView: UIView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var actionContent: UIView!
    
    private var _inEditingState :Bool = false
    private var _isActiveServer :Bool = false
    
    
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
    
    final func layoutCell(animated animated :Bool) {
        let duration = (animated) ? 0.5 : 0.1
        if !_inEditingState {
            
            let cons: NSLayoutConstraint? = self.contentView.constraints.first!
            cons?.constant = -58
            
            
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.contentView.layoutIfNeeded()
                }, completion: { (successed :Bool) -> Void in
                    if self._isActiveServer {
                        self.actionButton.setImage(UIImage(named: "server_indicator_active"), forState: UIControlState.Normal)
                    } else {
                        self.actionButton.setImage(UIImage(named: "server_indicator_passive"), forState: UIControlState.Normal)
                    }
                    
            })
        } else {
            
            let cons: NSLayoutConstraint? = self.contentView.constraints.first
            cons?.constant = 0
            
            
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.contentView.layoutIfNeeded()
                }, completion: { (successed :Bool) -> Void in
                    
                    self.actionButton.setImage(UIImage(named: "delete_icon"), forState: UIControlState.Normal)
            })
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    @IBAction func deleteCell(sender: AnyObject){
        
        if _inEditingState {
            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(ServerCellDelegate.deleteCell(_:))) {
                (self.delegate as! ServerCellDelegate).deleteCell!(self)
            }
        } else {
            super.setSelected(true, animated: true)
        }
    }
}
