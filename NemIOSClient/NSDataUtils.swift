import UIKit

extension NSData
{
    func hexadecimalString() -> String
    {
        var string = NSMutableString(capacity: length * 2)
        var byte: UInt8?
        
        for i in 0 ..< length
        {
            getBytes(&byte, range: NSMakeRange(i, 1))
            string.appendFormat("%02x", byte!)
        }
        
        return string as NSString as! String
    }
}