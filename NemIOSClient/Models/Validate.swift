import UIKit

class Validate: NSObject
{
    final class func address(inputText :String? ,length: Int = 64) -> Bool
    {
        if inputText == nil
        {
            return false
        }
        
        var validator :Array<UInt8> = Array<UInt8>("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ".utf8)
        var keyArray :Array<UInt8> = Array<UInt8>(inputText!.utf8)
        
        if keyArray.count == length
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
    
    final class func key(inputText :String? ,length: Int = 64) -> Bool
    {
        if inputText == nil
        {
            return false
        }
        
        var validator :Array<UInt8> = Array<UInt8>("0123456789abcdef".utf8)
        var keyArray :Array<UInt8> = Array<UInt8>(inputText!.utf8)
        
        if keyArray.count == length
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
        
        if keyArray.count < 6
        {
            return false
        }
                
        return true
    }
}
