import UIKit

class FilterButton: UIButton {

    var isFilterActive = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addTarget(self, action: "touchUpInside", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    final func touchUpInside() {
        if isFilterActive {
            self.setImage(UIImage(named: "logo _passive"), forState: UIControlState.Normal)
        }
        else {
            self.setImage(UIImage(named: "logo _active"), forState: UIControlState.Normal)
        }
        
        isFilterActive = !isFilterActive
    }
}
