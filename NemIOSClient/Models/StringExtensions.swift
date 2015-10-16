import UIKit
import CryptoSwift

extension String
{
    func dataFromHexadecimalString() -> NSData? {
        let trimmedString = self.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<> ")).stringByReplacingOccurrencesOfString(" ", withString: "")
        
        let regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: "^[0-9a-f]*$", options: .CaseInsensitive)
        } catch {
            regex = nil
        }
        
        let found = regex?.firstMatchInString(trimmedString, options: [], range: NSMakeRange(0, trimmedString.characters.count))
        
        if found == nil || found?.range.location == NSNotFound || trimmedString.characters.count % 2 != 0 {
            return nil
        }
        
        let data = NSMutableData(capacity: trimmedString.characters.count / 2)
        
        for var index = trimmedString.startIndex; index < trimmedString.endIndex; index = index.successor().successor() {
            let byteString = trimmedString.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
            let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
            data?.appendBytes([num] as [UInt8], length: 1)
        }
        
        return data
    }
    
    func stringFromHexadecimalStringUsingEncoding(encoding: NSStringEncoding) -> String? {
        if let data = dataFromHexadecimalString() {
            return NSString(data: data, encoding: encoding) as? String
        }
        
        return nil
    }
    
    func hexadecimalStringUsingEncoding(encoding: NSStringEncoding) -> String? {
        let data = dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        return data?.hexadecimalString()
    }
    
    func asByteArray()-> Array<UInt8> {
        var arrayLength :Int = self.utf16.count
        var hexString = self
        
        if arrayLength % 2 != 0 {
            hexString  = "0" + hexString
            arrayLength++
        }
        
        arrayLength = arrayLength / 2
        
        var buffer : Array<UInt8> = Array(count: arrayLength , repeatedValue: 0)
        for var index :Int = 0 ; index < arrayLength  ; index++ {
            let substring :String = (hexString as NSString).substringWithRange(NSRange(location: 2 * index, length: 2))
            buffer[index] = UInt8(substring, radix: 16)!
        }
        return buffer
    }
    
    func asByteArray(length: Int)-> Array<UInt8> {
        var arrayLength :Int = self.utf16.count
        var hexString = self
        
        if arrayLength % 2 != 0 {
            hexString  = "0" + hexString
            arrayLength++
        }
        
        arrayLength = arrayLength / 2
        
        var buffer : Array<UInt8> = Array(count: length , repeatedValue: 0)
        for var index :Int = 0 ; index < arrayLength  ; index++ {
            let substring :String = (hexString as NSString).substringWithRange(NSRange(location: 2 * index, length: 2))
            buffer[index] = UInt8(substring, radix: 16)!
        }
        
        return buffer
    }
    
    func asByteArrayEndian(length: Int)-> Array<UInt8> {
        var arrayLength :Int = self.utf16.count
        var hexString = self
        
        if arrayLength % 2 != 0 {
            hexString  = "0" + hexString
            arrayLength++
        }
        
        arrayLength = arrayLength / 2
        
        var buffer : Array<UInt8> = Array(count: length , repeatedValue: 0)
        for var index :Int = 0 ; index < arrayLength  ; index++ {
            let substring :String = (hexString as NSString).substringWithRange(NSRange(location: 2 * index, length: 2))
            buffer[arrayLength - index - 1] = UInt8(substring, radix: 16)!
        }
        
        return buffer
    }
}