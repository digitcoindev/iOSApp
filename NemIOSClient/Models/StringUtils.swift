import UIKit

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
    
    func asByteArray()-> Array<UInt8>
    {
        var arrayLength :Int = self.utf16Count / 2
        var buffer : Array<UInt8> = Array(count: arrayLength , repeatedValue: 0)
        for var index :Int = 0 ; index < arrayLength  ; index++
        {
            var substring :String = (self as NSString).substringWithRange(NSRange(location: 2 * index, length: 2))
            buffer[index] = UInt8(substring, radix: 16)!
        }
        return buffer
    }
}