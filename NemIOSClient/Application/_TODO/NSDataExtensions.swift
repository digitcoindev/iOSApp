import UIKit
import CryptoSwift

extension Data
{
    func hexadecimalString() -> String {
        let string = NSMutableString(capacity: count * 2)
        var byte: UInt8 = UInt8()
        
        for i in 0 ..< count {
            copyBytes(to: &byte, from: i..<1)
            string.appendFormat("%02x", byte)
        }
        
        return string as NSString as String
    }
    
    func aesEncrypt(_ key: [UInt8], iv: [UInt8]) -> Data? {
        let enc = try! AES(key: key, iv: iv, blockMode: .CBC).encrypt(self)
        let encData = Data(bytes: enc)
        return encData
    }
    
    func aesDecrypt(_ key: [UInt8], iv: [UInt8]) -> Data? {
        guard let dec = try? AES(key: key, iv: iv, blockMode:.CBC).decrypt(self) else { return nil }
        let decData = Data(bytes: dec)
        return decData
    }
}

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
        let array = Array(UnsafeBufferPointer(start: self.bytes.assumingMemoryBound(to: UInt8.self), count: self.length))

        let enc = try! AES(key: key, iv: iv, blockMode:.CBC).encrypt(array)
        let encData = NSData(bytes: enc, length: Int(enc.count))
        return encData
    }
    
    func aesDecrypt(key: [UInt8], iv: [UInt8]) -> NSData? {
//        let array = Array(UnsafeBufferPointer(start: self.bytes.assumingMemoryBound(to: UInt8.self), count: self.length))
//
//        guard let dec = try? AES(key: key, iv: iv, blockMode:.CBC).decrypt(array) else { return nil }
//        let decData = NSData(bytes: dec, length: Int(dec.count))
//        
//        print("----- \(decData)")
//        return decData
        
        guard let dec = try? AES(key: key, iv: iv, blockMode:.CBC, padding: PKCS7()).decrypt(self.arrayOfBytes()) else { return nil }
        let decData = NSData(bytes: dec, length: Int(dec.count))
        
        return decData
    }
}
