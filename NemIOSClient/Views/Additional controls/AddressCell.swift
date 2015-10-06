import UIKit

class AddressCell: EditableTableViewCell
{
    
    // MARK: properties
    
    let infoLabel: UILabel = UILabel()
    let icon: UIImageView = UIImageView()
    
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
            
            let duration = (_isAddress == newValue) ? 0.01 : 0.2
            _isAddress = newValue
            
            UIView.animateWithDuration(duration) { () -> Void in
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
}
