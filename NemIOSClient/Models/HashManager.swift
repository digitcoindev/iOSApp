
import UIKit

class HashManager: NSObject
{
    class func AES256Encrypt(inputText :String) -> String
    {
        var dataBytes = inputText.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var randomIV =  NSData().generateRandomIV(11).base64EncodingWithLineLength(0)
        var customizedIV =  randomIV.substringToIndex(advance(randomIV.startIndex, 16))
        
        var key = "wD7Y9WTxRdKTWU9iJs14sA==lXBSGon1vCyRdss="
        
        var encryptedData = dataBytes.AES256EncryptWithKey(key, iv: customizedIV)
        var encryptedText = encryptedData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
            encryptedText = encryptedText + customizedIV
        
        return encryptedText
    }
    
    class func AES256Encrypt(inputText :String ,key :String) -> String
    {
        var dataBytes = inputText.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var randomIV =  NSData().generateRandomIV(11).base64EncodingWithLineLength(0)
        var customizedIV =  randomIV.substringToIndex(advance(randomIV.startIndex, 16))
        
        var encryptedData = dataBytes.AES256EncryptWithKey(key, iv: customizedIV)
        var encryptedText = encryptedData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
        encryptedText = encryptedText + customizedIV
        
        return encryptedText
    }
    
    class func AES256Decrypt(inputText :String) -> String
    {
        var customizedIV =  inputText.substringFromIndex(advance(inputText.endIndex, -16))
        var encryptedText = inputText.substringToIndex(advance(inputText.endIndex, -16))
        
        var key = "wD7Y9WTxRdKTWU9iJs14sA==lXBSGon1vCyRdss="
        
        let data :NSData = NSData(base64EncodedString: encryptedText , options: NSDataBase64DecodingOptions(0))!
        
        if(data.length > 0)
        {
            let decryptedData = data.AES256DecryptWithKey(key, iv: customizedIV)
            var decryptedText : String = NSString(data: decryptedData, encoding: NSUTF8StringEncoding) as String
            
            return decryptedText
        }
        else
        {
            println("ERROR : not encryptedText")
            return String()
        }
    }
    
    class func AES256Decrypt(inputText :String ,key :String) -> String
    {
        var customizedIV =  inputText.substringFromIndex(advance(inputText.endIndex, -16))
        var encryptedText = inputText.substringToIndex(advance(inputText.endIndex, -16))
        
        let data :NSData = NSData(base64EncodedString: encryptedText , options: NSDataBase64DecodingOptions(0))!
        
        if(data.length > 0)
        {
            let decryptedData = data.AES256DecryptWithKey(key, iv: customizedIV)
            var decryptedText : String = NSString(data: decryptedData, encoding: NSUTF8StringEncoding) as String
            
            return decryptedText
        }
        else
        {
            println("ERROR : not encryptedText")
            return String()
        }
    }
}


