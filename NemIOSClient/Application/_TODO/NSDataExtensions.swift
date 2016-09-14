import UIKit
import CryptoSwift

extension Data
{
    func hexadecimalString() -> String {
        let string = NSMutableString(capacity: count * 2)
        var byte: UInt8 = UInt8()
        
        for i in 0 ..< count {
            copyBytes(to: &byte, from: NSMakeRange(i, 1))
            string.appendFormat("%02x", byte)
        }
        
        return string as NSString as String
    }
    
    func aesEncrypt(_ key: [UInt8], iv: [UInt8]) -> Data? {
        let enc = try! AES(key: key, iv: iv, blockMode:.cbc, padding: PKCS7()).encrypt(self.arrayOfBytes())
        let encData = Data(bytes: UnsafePointer<UInt8>(enc), count: Int(enc.count))
        return encData
    }
    
    func aesDecrypt(_ key: [UInt8], iv: [UInt8]) -> Data? {
        guard let dec = try? AES(key: key, iv: iv, blockMode:.cbc, padding: PKCS7()).decrypt(self.arrayOfBytes()) else { return nil }
        let decData = Data(bytes: UnsafePointer<UInt8>(dec), count: Int(dec.count))
        return decData
    }
}
