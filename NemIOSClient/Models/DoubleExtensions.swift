import UIKit

extension Double
{
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as! String
    }
}