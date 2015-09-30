import UIKit

class Validate: NSObject
{
    final class func address(inputText :String? ,length: Int = 64) -> Bool {
        if inputText == nil {
            return false
        }
        
        let validator :Array<UInt8> = Array<UInt8>("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ".utf8)
        let keyArray :Array<UInt8> = Array<UInt8>(inputText!.utf8)
        
        if keyArray.count == length {
            for value in keyArray {
                var find = false
                
                for valueChecker in validator {
                    if value == valueChecker
                    {
                        find = true
                        break
                    }
                }
                
                if !find {
                    return false
                }
            }
        }
        else {
            return false
        }
        
        return true

    }
    
    final class func key(inputText :String? ,length: Int = 64) -> Bool {
        if inputText == nil {
            return false
        }
        
        let validator :Array<UInt8> = Array<UInt8>("0123456789abcdef".utf8)
        var keyArray :Array<UInt8> = Array<UInt8>(inputText!.utf8)
        
        if keyArray.count == length || keyArray.count == length + 2 {
            if keyArray.count == length + 2 {
                keyArray.removeAtIndex(0)
                keyArray.removeAtIndex(0)
            }
            
            for value in keyArray {
                var find = false
                
                for valueChecker in validator {
                    if value == valueChecker
                    {
                        find = true
                        break
                    }
                }
                
                if !find {
                    return false
                }
            }
        }
        else {
            return false
        }
        
        return true
    }
    
    final class func password(inputText :String) -> Bool {
        let keyArray :Array<UInt8> = Array<UInt8>(inputText.utf8)
        
        if keyArray.count < 6 {
            return false
        }
                
        return true
    }
    
    final class func stringNotEmpty(inputText :String?) -> Bool {
        if inputText == nil {
            return false
        }
        
        if inputText == "" {
            return false
        }
        
        return true
    }
    
    final class func hexString(text : String) -> Bool {
        let regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: "^[0-9a-f]*$", options: .CaseInsensitive)
        } catch {
            regex = nil
        }
        
        let found = regex?.firstMatchInString(text, options: [], range: NSMakeRange(0, text.characters.count))
        
        if found == nil || found?.range.location == NSNotFound || text.characters.count % 2 != 0 {
            return false
        }
        
        return true
    }
}
