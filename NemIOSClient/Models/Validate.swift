import UIKit

class Validate: NSObject
{
    final class func privateKey(inputText :String) -> Bool
    {
        var validator :Array<UInt8> = Array<UInt8>("0123456789abcdef".utf8)
        var keyArray :Array<UInt8> = Array<UInt8>(inputText.utf8)
        
        if keyArray.count == 64
        {
            for value in keyArray
            {
                var find = false
                
                for valueChecker in validator
                {
                    if value == valueChecker
                    {
                        find = true
                        break
                    }
                }
                
                if !find
                {
                    return false
                }
            }
        }
        else
        {
            return false
        }
        
        return true
    }
    
    final class func password(inputText :String) -> Bool
    {
        var keyArray :Array<UInt8> = Array<UInt8>(inputText.utf8)
        
        if keyArray.count >= 6
        {
            return true
        }
        else
        {
            return false
        }
        
        return true
    }
}
