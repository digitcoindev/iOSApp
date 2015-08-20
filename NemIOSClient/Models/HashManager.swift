
import UIKit


class HashManager: NSObject
{
    final class func AES256Encrypt(inputText :String ,key :String? = nil) -> String {
        var dataBytes = inputText.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var randomIV =  NSData().generateRandomIV(11).base64EncodingWithLineLength(0)
        var customizedIV =  randomIV.substringToIndex(advance(randomIV.startIndex, 16))
        
        var inKey :String = "wD7Y9WTxRdKTWU9iJs14sA==lXBSGon1vCyRdss="
        
        if key != nil {
            inKey = key!
        }
        
        var encryptedData = dataBytes.AES256EncryptWithKey(inKey, iv: customizedIV)
        var encryptedText = encryptedData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
            encryptedText = encryptedText + customizedIV
        
        return encryptedText
    }
    
    final class func AES256Decrypt(inputText :String ,key :String? = nil) -> String {
        var customizedIV =  inputText.substringFromIndex(advance(inputText.endIndex, -16))
        var encryptedText = inputText.substringToIndex(advance(inputText.endIndex, -16))
        var inKey :String = "wD7Y9WTxRdKTWU9iJs14sA==lXBSGon1vCyRdss="
        
        if key != nil {
            inKey = key!
        }
        
        let data :NSData = NSData(base64EncodedString: encryptedText , options: NSDataBase64DecodingOptions(0))!
        
        if(data.length > 0) {
            let decryptedData = data.AES256DecryptWithKey(inKey, iv: customizedIV)
            var decryptedText : String = NSString(data: decryptedData, encoding: NSUTF8StringEncoding) as! String
            
            return decryptedText
        }
        else {
            println("ERROR : not encryptedText")
            return String()
        }
    }
       
    final func SHA256Encrypt(inputText: String)->String {
        var outBuffer: Array<UInt8> = Array(count: 64, repeatedValue: 0)
        var inBuffer: Array<UInt8> = Array(inputText.utf8)
        var len :Int32 = Int32(inBuffer.count)
        SHA256_hash(&outBuffer, &inBuffer, len)
        
        let hash :String = NSString(bytes: outBuffer, length: outBuffer.count, encoding: NSUTF8StringEncoding) as! String
        
        return hash
    }
    
    final func RIPEMD160Encrypt(inputText: String)->String {
        return RIPEMD.asciiDigest(inputText) as String
    }
    
    final class func salt(#length:Int) -> NSData {
        let data = NSMutableData(length: Int(length))
        let result = SecRandomCopyBytes(kSecRandomDefault, length, UnsafeMutablePointer<UInt8>(data!.mutableBytes))
        
        return data!
    }
    
    final class func generateAesKeyForString(string: String, salt: NSData, roundCount: Int?, error: NSErrorPointer) -> NSData? {
        let nsDerivedKey = NSMutableData(length: 128)
        var actualRoundCount: UInt32
        
        let algorithm: CCPBKDFAlgorithm        = CCPBKDFAlgorithm(kCCPBKDF2)
        let prf:       CCPseudoRandomAlgorithm = CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1)
        let saltBytes  = UnsafePointer<UInt8>(salt.bytes)
        let saltLength = size_t(salt.length)
        let nsPassword        = string as NSString
        let nsPasswordPointer = UnsafePointer<Int8>(nsPassword.cStringUsingEncoding(NSUTF8StringEncoding))
        let nsPasswordLength  = size_t(nsPassword.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        var nsDerivedKeyPointer = UnsafeMutablePointer<UInt8>(nsDerivedKey!.mutableBytes)
        let nsDerivedKeyLength = size_t(nsDerivedKey!.length)
        let msec: UInt32 = 300
        
        if roundCount != nil {
            actualRoundCount = UInt32(roundCount!)
        }
        else {
            actualRoundCount = CCCalibratePBKDF(
                algorithm,
                nsPasswordLength,
                saltLength,
                prf,
                nsDerivedKeyLength,
                msec);
        }
        
        let result = CCKeyDerivationPBKDF(
            algorithm,
            nsPasswordPointer,   nsPasswordLength,
            saltBytes,           saltLength,
            prf,                 actualRoundCount,
            nsDerivedKeyPointer, nsDerivedKeyLength)
        
        if result != 0 {
            let errorDescription = "CCKeyDerivationPBKDF failed with error: '\(result)'"
            
            return nil
        }
        
        return nsDerivedKey!
    }
    
    
}


