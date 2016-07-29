//
//  AddressBookContactTableViewCell.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class AddressBookContactTableViewCell: EditableTableViewCell
{
    
    // MARK: properties
    
    let infoLabel: UILabel = UILabel()
    let icon: UIImageView = UIImageView()
    
    // MARK: Private values 
    
    private var _defaultColor :UIColor = UIColor.whiteColor()
    
    var isAddress :Bool {
        get {
            return _isAddress ?? false
        }
        
        set {
            if _isAddress == nil
            {
                _isAddress = newValue
                layoutSubviews()
                return
            }
            
            _isAddress = newValue

            if newValue {
                
                let duration = (_isAddress == newValue) ? 0.01 : 0.2
                
                UIView.animateWithDuration(duration) { () -> Void in
                    self.layoutSubviews()
                }
            } else {
                self.layoutSubviews()
            }
        }
    }
    
    // MARK: private variables
    
    private var _isAddress: Bool? = nil
    
    // MARK: inizializers

    override func awakeFromNib() {
        super.awakeFromNib()
        
        infoLabel.text = "loading ..."
        icon.image = UIImage(named: "logo _active")
        
        _contentView?.addSubview(infoLabel)
        _contentView?.addSubview(icon)
    }
    
    // MARK: layout

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isAddress {
            icon.frame = CGRect(x: _contentView!.frame.width - _contentView!.frame.height - 10 , y: 0, width: _contentView!.frame.height, height: _contentView!.frame.height)
        } else {
            icon.frame = CGRect(x: _contentView!.frame.width - 10, y: 0, width: 0, height: _contentView!.frame.height)
        }
        
        infoLabel.frame = CGRect(x: _SEPARATOR_OFFSET_, y: 0, width:icon.frame.origin.x - 10 , height: _contentView!.frame.height)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func selectContact() {
        _contentView?.backgroundColor = UIColor(red: 51 / 256 , green: 191 / 256 , blue: 86 / 256 , alpha: 1)
        
        let delay = 2.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            self.deselectContact()
        })
    }
    
    func deselectContact() {
        _contentView?.backgroundColor = _defaultColor
    }
}
