import UIKit

class FilterButton: UIButton {
    
    fileprivate var _isFilterActive = true
    
    var isFilterActive :Bool {
        get {
            return _isFilterActive
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addTarget(self, action: #selector(FilterButton.touchUpInside), for: UIControlEvents.touchUpInside)
    }
    
    final func touchUpInside() {
        
        setFilterToState(nil)
    }
    
    final func setFilterToState(_ active: Bool?) {
        
        if active != nil {
            _isFilterActive = active!
        } else {
            _isFilterActive = !_isFilterActive
        }
        
        if _isFilterActive {
            self.setImage(UIImage(named: "logo _active"), for: UIControlState())
        }
        else {
            self.setImage(UIImage(named: "logo _passive"), for: UIControlState())
        }
    }
}
