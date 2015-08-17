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
            _inEditingState = newValue
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
    
    var delegate :AnyObject? = nil
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        _inEditingState = false
        self.contentView.clipsToBounds = true
    }
    
    final func layoutCell(#animated :Bool) {
        var duration = (animated) ? 0.5 : 0.1
        if !_inEditingState {
            
            var cons: NSLayoutConstraint? = self.contentView.constraints().first as? NSLayoutConstraint
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
            
            var cons: NSLayoutConstraint? = self.contentView.constraints().first as? NSLayoutConstraint
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
        
        if _inEditingState
        {
            if self.delegate != nil && self.delegate!.respondsToSelector("deleteCell:") {
                (self.delegate as! ServerCellDelegate).deleteCell!(self)
            }
        }
    }
}
