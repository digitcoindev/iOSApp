import UIKit

protocol EditableTableViewCellDelegate
{
    func deleteCell(cell: EditableTableViewCell)
}

class EditableTableViewCell: AbstactTableViewCell
{
    // MARK: internal variables

    internal let _editView: UIView? = UIView()
    internal let _deleteView: UIView? = UIView()

    // MARK: properties
    
    var editDelegate :EditableTableViewCellDelegate?
    
    var isEditable :Bool {
            get {
                return _isEditable ?? false
            }
            
            set {
                if _isEditable == nil
                {
                    _isEditable = newValue
                    layoutSubviews()
                    return
                }
                
                let duration = (_isEditable == newValue) ? 0.01 : 0.2
                _isEditable = newValue
                
                UIView.animateWithDuration(duration) { () -> Void in
                    self.layoutSubviews()
                }
            }
    }
    
    // MARK: private variables

    private var _isEditable : Bool? = nil
    private let _editImageView: UIImageView = UIImageView()
    private let _deleteButton :UIButton = UIButton(type: UIButtonType.Custom)

    // MARK: inizializers

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addSubview(_editView!)
        self.addSubview(_deleteView!)
        
        _editImageView.image = UIImage(named: "edit_account_icon")
        _editImageView.contentMode = .ScaleAspectFit
        
        self._editView?.addSubview(_editImageView)
        
        _deleteButton.setBackgroundImage(UIImage(named: "delete_icon"), forState: UIControlState.Normal)
        _deleteButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        _deleteButton.addTarget(self, action: "deleteCell", forControlEvents: UIControlEvents.TouchUpInside)
        
        self._deleteView?.addSubview(_deleteButton)
        
    }
    
    // MARK: layout

    override func layoutSubviews() {
        super.layoutSubviews()
        
        _editImageView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        _editImageView.center = CGPoint(x: _editImageView.center.x, y: self.frame.height / 2)
        
        _deleteButton.frame = CGRect(x: _SMALL_OFFSET_ , y: self.frame.height / 8, width: self.frame.height * 0.75, height: self.frame.height * 0.75)
        
        var _accum: CGFloat = _editImageView.frame.origin.x + _editImageView.frame.width
        
        if isEditable {
            _editView?.frame = CGRect(x: -_accum, y: 0, width: _accum, height: self.frame.height)
            
            _deleteView?.frame = CGRect(x: self.frame.width, y: 0, width: _deleteButton.frame.width + _SMALL_OFFSET_ + _SEPARATOR_OFFSET_, height: self.frame.height)
        } else {
            _editView?.frame = CGRect(x: _SEPARATOR_OFFSET_, y: 0, width: _accum, height: self.frame.height)
            
            _accum = _deleteButton.frame.width + _SMALL_OFFSET_ + _SEPARATOR_OFFSET_
            
            _deleteView?.frame = CGRect(x: self.frame.width - _accum , y: 0, width: _accum, height: self.frame.height)
        }
        
        _accum = _editView!.frame.origin.x + _editView!.frame.width
        
        _contentView?.frame = CGRect(x: _accum, y: 0, width: _deleteView!.frame.origin.x - _accum, height: self.frame.height)
    }
    
    // MARK: Actions
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func deleteCell()
    {
        if self.editDelegate != nil
        {
            editDelegate?.deleteCell(self)
        }
    }
}
