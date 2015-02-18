import UIKit

class NEMTextField: UITextField
{
    
    override func textRectForBounds(bounds: CGRect) -> CGRect
    {
        return CGRectInset(bounds, 10, 10)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect
    {
        return textRectForBounds(bounds)
    }
}
