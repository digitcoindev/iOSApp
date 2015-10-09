import UIKit

class FilterButton: UIButton {
    
    private var _isFilterActive = true
    
    var isFilterActive :Bool {
        get {
            return _isFilterActive
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addTarget(self, action: "touchUpInside", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    final func touchUpInside() {
        
        setFilterToState(nil)
    }
    
    final func setFilterToState(active: Bool?) {
        
        if active != nil {
            _isFilterActive = active!
        } else {
            _isFilterActive = !_isFilterActive
        }
        
        if _isFilterActive {
            self.setImage(UIImage(named: "logo _active"), forState: UIControlState.Normal)
        }
        else {
            self.setImage(UIImage(named: "logo _passive"), forState: UIControlState.Normal)
        }
    }
}
