import UIKit

class FilterButton: UIButton {

    var isFilterActive = true
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.addTarget(self, action: "touchUpInside", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    final func touchUpInside()
    {
        if isFilterActive
        {
            self.setImage(UIImage(named: "logged_icon.png"), forState: UIControlState.Normal)
        }
        else
        {
            self.setImage(UIImage(named: "NEM_shield_logo.png"), forState: UIControlState.Normal)
        }
        
        isFilterActive = !isFilterActive
    }
}
