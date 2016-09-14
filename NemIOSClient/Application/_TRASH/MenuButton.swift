import UIKit

class MenuButton: UIButton
{
    override var isHighlighted: Bool  {

        didSet {

            if (isHighlighted) {
                self.setTitleColor(UIColor.white, for: UIControlState())
            }
            else {
                self.setTitleColor(UIColor.white, for: UIControlState())
            }
        }
    }
}
