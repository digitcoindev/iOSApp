
import UIKit


class HashManager: NSObject
{
    final class func AES256Encrypt(inputText :String ,key :String? = nil) -> String {
        let dataBytes = inputText.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let randomIV =  NSData().generateRandomIV(11).base64EncodingWithLineLength(0)
        let customizedIV =  randomIV.substringToIndex(randomIV.startIndex.advancedBy(16))
        
        var inKey :String = "wD7Y9WTxRdKTWU9iJs14sA==lXBSGon1vCyRdss="
        
        if key != nil {
            inKey = key!
        }
        
        let encryptedData = dataBytes.AES256EncryptWithKey(inKey, iv: customizedIV)
        var encryptedText = encryptedData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            encryptedText = encryptedText + customizedIV
        
        return encryptedText
    }
    
    final class func AES256Decrypt(inputText :String ,key :String? = nil) -> String {
        let customizedIV =  inputText.substringFromIndex(inputText.endIndex.advancedBy(-16))
        let encryptedText = inputText.substringToIndex(inputText.endIndex.advancedBy(-16))
        var inKey :String = "wD7Y9WTxRdKTWU9iJs14sA==lXBSGon1vCyRdss="
        
        if key != nil {
            inKey = key!
        }
        
        let data :NSData = NSData(base64EncodedString: encryptedText , options: NSDataBase64DecodingOptions(rawValue: 0))!
        
        if(data.length > 0) {
            let decryptedData = data.AES256DecryptWithKey(inKey, iv: customizedIV)
            let decryptedText : String = NSString(data: decryptedData, encoding: NSUTF8StringEncoding) as! String
            
            return decryptedText
        }
        else {
            print("ERROR : not encryptedText")
            return String()
        }
    }
       
    final class func SHA256Encrypt(data :[UInt8])->String {
        var outBuffer: Array<UInt8> = Array(count: 64, repeatedValue: 0)
        var inBuffer: Array<UInt8> = Array(data)
        let len :Int32 = Int32(inBuffer.count)
        SHA256_hash(&outBuffer, &inBuffer, len)
        
        let hash :String = NSString(bytes: outBuffer, length: outBuffer.count, encoding: NSUTF8StringEncoding) as! String
        
        return hash
    }
    
    final func RIPEMD160Encrypt(inputText: String)->String {
        return RIPEMD.asciiDigest(inputText) as String
    }
    
    final class func salt(length length:Int) -> NSData {
        let data = NSMutableData(length: Int(length))
                
        return data!
    }
    
    final class func generateAesKeyForString(string: String, salt: NSData, roundCount: Int?) throws -> NSData? {
        let error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        let nsDerivedKey = NSMutableData(length: 128)
        var actualRoundCount: UInt32
        
        let algorithm: CCPBKDFAlgorithm        = CCPBKDFAlgorithm(kCCPBKDF2)
        let prf:       CCPseudoRandomAlgorithm = CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1)
        let saltBytes  = UnsafePointer<UInt8>(salt.bytes)
        let saltLength = size_t(salt.length)
        let nsPassword        = string as NSString
        let nsPasswordPointer = UnsafePointer<Int8>(nsPassword.cStringUsingEncoding(NSUTF8StringEncoding))
        let nsPasswordLength  = size_t(nsPassword.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let nsDerivedKeyPointer = UnsafeMutablePointer<UInt8>(nsDerivedKey!.mutableBytes)
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
            throw error
        }
        
        return nsDerivedKey!
    }
    
    
}


