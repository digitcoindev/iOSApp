import UIKit

class HexManager: NSObject
{
    
    final func stringWithHexString(hex: String) -> String
    {
        var hex = hex
        var result: String = ""
        
        while(countElements(hex) > 0)
        {
            var substring: String = hex.substringToIndex(advance(hex.startIndex, 2))
            hex = hex.substringFromIndex(advance(hex.startIndex, 2))
            var character: UInt32 = 0
            NSScanner(string: substring).scanHexInt(&character)
            result = result.stringByAppendingString(String(format: "%c", character))
        }
        
        return result
    }
    
    
}
extension String
{
    func dataFromHexadecimalString() -> NSData?
    {
        let trimmedString = self.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<> ")).stringByReplacingOccurrencesOfString(" ", withString: "")
        
        var error: NSError?
        let regex = NSRegularExpression(pattern: "^[0-9a-f]*$", options: .CaseInsensitive, error: &error)
        let found = regex?.firstMatchInString(trimmedString, options: nil, range: NSMakeRange(0, countElements(trimmedString)))
        
        if found == nil || found?.range.location == NSNotFound || countElements(trimmedString) % 2 != 0
        {
            return nil
        }
        
        let data = NSMutableData(capacity: countElements(trimmedString) / 2)
        
        for var index = trimmedString.startIndex; index < trimmedString.endIndex; index = index.successor().successor()
        {
            let byteString = trimmedString.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
            let num = Byte(byteString.withCString { strtoul($0, nil, 16) })
            data?.appendBytes([num] as [Byte], length: 1)
        }
        
        return data
    }
    
    func stringFromHexadecimalStringUsingEncoding(encoding: NSStringEncoding) -> String?
    {
        if let data = dataFromHexadecimalString()
        {
            return NSString(data: data, encoding: encoding) as? String
        }
        
        return nil
    }
    
    func hexadecimalStringUsingEncoding(encoding: NSStringEncoding) -> String?
    {
        let data = dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        return data?.hexadecimalString()
    }
}

extension NSData
{
    func hexadecimalString() -> String
    {
        var string = NSMutableString(capacity: length * 2)
        var byte: Byte?
        
        for i in 0 ..< length
        {
            getBytes(&byte, range: NSMakeRange(i, 1))
            string.appendFormat("%02x", byte!)
        }
        
        return string
    }
}