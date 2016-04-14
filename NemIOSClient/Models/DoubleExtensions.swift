import UIKit

extension Double
{
    func format(maximumFractionDigits maximumFractionDigits :Int = 6) -> String {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.decimalSeparator = "."
        numberFormatter.groupingSeparator = " "
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = maximumFractionDigits
        let finalNumber = numberFormatter.stringFromNumber(self)
        return finalNumber!
    }
}