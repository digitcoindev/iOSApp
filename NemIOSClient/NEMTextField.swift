import UIKit

class NEMTextField: UITextField
{
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        let rect = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.width - 15, bounds.height)
        return CGRectInset(rect, 10, 10)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }
}
