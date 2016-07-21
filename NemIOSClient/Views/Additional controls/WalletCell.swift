import UIKit

class WalletCell: EditableTableViewCell
{
    // MARK: properties
    
    let infoLabel: UILabel = UILabel()
    
    // MARK: inizializers
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        infoLabel.text = "loading ..."
        infoLabel.numberOfLines = 2
        
        _contentView?.addSubview(infoLabel)
    }
    
    // MARK: layout
    
    override func layoutSubviews() {
        super.layoutSubviews()

        for subview in subviews {
            if  subview.dynamicType.description().rangeOfString("Reorder") != nil {
                
                subview.frame.origin.x = 0
                subview.frame.size.width = 45
                
                for view in subview.subviews {
                    if view.isKindOfClass(UIImageView) {
                        let center = view.center
                        view.frame.size = CGSize(width: 15, height: 15)
                        view.center = center
                        
                        (view as! UIImageView).contentMode = .ScaleAspectFit
                        (view as! UIImageView).image = UIImage(named: "sort_icon")
                    }
                }
            }
        }
        
        if isEditable {
            let relativeChange = max(45, _editView!.frame.origin.x) - _editView!.frame.origin.x
            _editView?.frame.origin.x += relativeChange
            _contentView?.frame.origin.x += relativeChange
            _contentView?.frame.size.width -= relativeChange
        }
        
        infoLabel.frame = CGRect(x: _SEPARATOR_OFFSET_, y: 0, width: _contentView!.frame.width - _SEPARATOR_OFFSET_ * 2 , height: _contentView!.frame.height)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
