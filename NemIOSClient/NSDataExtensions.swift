import UIKit
import CryptoSwift

extension NSData
{
    func hexadecimalString() -> String {
        let string = NSMutableString(capacity: length * 2)
        var byte: UInt8 = UInt8()
        
        for i in 0 ..< length {
            getBytes(&byte, range: NSMakeRange(i, 1))
            string.appendFormat("%02x", byte)
        }
        
        return string as NSString as String
    }
    
    func aesEncrypt(key: [UInt8], iv: [UInt8]) -> NSData? {
        let enc = try! AES(key: key, iv: iv, blockMode:.CBC, padding: PKCS7()).encrypt(self.arrayOfBytes())
        let encData = NSData(bytes: enc, length: Int(enc.count))
        return encData
    }
    
    func aesDecrypt(key: [UInt8], iv: [UInt8]) -> NSData? {
        guard let dec = try? AES(key: key, iv: iv, blockMode:.CBC, padding: PKCS7()).decrypt(self.arrayOfBytes()) else { return nil }
        let decData = NSData(bytes: dec, length: Int(dec.count))
        return decData
    }
}