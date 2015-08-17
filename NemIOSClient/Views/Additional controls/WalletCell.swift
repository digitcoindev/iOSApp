import UIKit

@objc protocol WalletCellDelegate
{
    optional func deleteCell(cell :UITableViewCell)
}

class WalletCell: UITableViewCell
{
    @IBOutlet weak var walletName: UILabel!
    @IBOutlet weak var editingView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var inEditingState :Bool = false
    var delegate :AnyObject? = nil
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        inEditingState = false
        }
    
    override func layoutSubviews() {
        layoutCell(animated: false)
    }
    
    final func layoutCell(#animated :Bool) {
        var duration = (animated) ? 0.5 : 0.1
        
        if !inEditingState {
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.editingView.frame = CGRect(x: -self.editingView.frame.width,
                                                y: 0,
                                                width: self.editingView.frame.width,
                                                height: self.editingView.frame.height)
                
                self.walletName.frame = CGRect( x: 15,
                                                y: 0,
                                                width: self.bounds.width - 15,
                                                height: self.bounds.height)
            })
            deleteButton.hidden = true
            
        } else {
            
            UIView.animateWithDuration(duration, animations: { () -> Void in
                
                self.editingView.frame = CGRect(x: 15,
                    y: 0,
                    width: self.editingView.frame.width,
                    height: self.editingView.frame.height)
                
                            
                self.walletName.frame = CGRect( x: self.editingView.frame.width + self.editingView.frame.origin.x,
                                                y: 0,
                                                width: self.bounds.width - self.editingView.bounds.width - self.deleteButton.frame.width,
                                                height: self.bounds.height)
            })
            
            deleteButton.hidden = false
        }
        
        inEditingState = !inEditingState
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    @IBAction func deleteCell(sender: AnyObject){
        if self.delegate != nil && self.delegate!.respondsToSelector("deleteCell:") {
            (self.delegate as! WalletCellDelegate).deleteCell!(self)
        }
    }

}
