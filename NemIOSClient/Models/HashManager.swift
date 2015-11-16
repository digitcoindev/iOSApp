
import UIKit


class HashManager: NSObject
{
    final class func AES256Encrypt(inputText :String ,key :String) -> String {
        let messageBytes = inputText.asByteArray()
        var messageData = NSData(bytes: messageBytes, length: messageBytes.count)

        let ivData = NSData().generateRandomIV(16)
        let customizedIVBytes: Array<UInt8> = Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(ivData.bytes), count: ivData.length))
        messageData = messageData.aesEncrypt(key.asByteArray(), iv: customizedIVBytes)!
        
        return customizedIVBytes.toHexString() + messageData.toHexString()
    }
    
    final class func AES256Decrypt(inputText :String ,key :String) -> String? {
        let inputBytes = inputText.asByteArray()
        let customizedIV =  Array(inputBytes[0..<16])
        let encryptedBytes = Array(inputBytes[16..<inputBytes.count])
        
        var data :NSData = NSData(bytes: encryptedBytes, length: encryptedBytes.count)
        
        data = data.aesDecrypt(key.asByteArray(), iv: customizedIV)!
        
        return data.toHexString()
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
        let nsDerivedKey = NSMutableData(length: 32)
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


