import UIKit

class MenuButton: UIButton
{
    override var highlighted: Bool 
        {

        didSet
        {

            if (highlighted)
            {
                self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            }
            else
            {
                self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            }
        }
    }
}
