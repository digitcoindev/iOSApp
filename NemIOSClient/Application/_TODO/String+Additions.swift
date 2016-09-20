import UIKit
import CryptoSwift

extension String
{
    
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
    
    var UTF8EncodedData: Data {
        return self.data(using: String.Encoding.utf8)!
    }
    
//    func dataFromHexadecimalString() -> Data? {
//        let trimmedString = self.trimmingCharacters(in: CharacterSet(charactersIn: "<> ")).replacingOccurrences(of: " ", with: "")
//        
//        let regex: NSRegularExpression?
//        do {
//            regex = try NSRegularExpression(pattern: "^[0-9a-f]*$", options: .caseInsensitive)
//        } catch {
//            regex = nil
//        }
//        
//        let found = regex?.firstMatch(in: trimmedString, options: [], range: NSMakeRange(0, trimmedString.characters.count))
//        
//        if found == nil || found?.range.location == NSNotFound || trimmedString.characters.count % 2 != 0 {
//            return nil
//        }
//        
//        let data = NSMutableData(capacity: trimmedString.characters.count / 2)
//        
//        for var index = trimmedString.startIndex; index < trimmedString.endIndex; index = index.successor().successor() {
//
//            let byteString = trimmedString.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
//            
//            
//            let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
//            data?.appendBytes([num] as [UInt8], length: 1)
//        }
//        
//        return data as Data?
//    }
    
    func path() -> String
    {
        let _documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        
        let path = (_documentsPath as NSString).appendingPathComponent(self)
        
        return path
    }
    
//    func stringFromHexadecimalStringUsingEncoding(_ encoding: String.Encoding) -> String? {
//        if let data = dataFromHexadecimalString() {
//            return NSString(data: data, encoding: encoding.rawValue) as? String
//        }
//        
//        return nil
//    }
    
    func hexadecimalStringUsingEncoding(_ encoding: String.Encoding) -> String? {
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        return data?.hexadecimalString()
    }
    
    func asByteArray()-> Array<UInt8> {
        var arrayLength :Int = self.utf16.count
        var hexString = self
        
        if arrayLength % 2 != 0 {
            hexString  = "0" + hexString
            arrayLength += 1
        }
        
        arrayLength = arrayLength / 2
        
        var buffer : Array<UInt8> = Array(repeating: 0 , count: arrayLength)
        for index :Int in 0  ..< arrayLength  {
            let substring :String = (hexString as NSString).substring(with: NSRange(location: 2 * index, length: 2))
            buffer[index] = UInt8(substring, radix: 16)!
        }
        return buffer
    }
    
    func asByteArray(_ length: Int)-> Array<UInt8> {
        var arrayLength :Int = self.utf16.count
        var hexString = self
        
        if arrayLength % 2 != 0 {
            hexString  = "0" + hexString
            arrayLength += 1
        }
        
        arrayLength = arrayLength / 2
        
        var buffer : Array<UInt8> = Array(repeating: 0 , count: length)
        for index :Int in 0  ..< arrayLength  {
            let substring :String = (hexString as NSString).substring(with: NSRange(location: 2 * index, length: 2))
            buffer[index] = UInt8(substring, radix: 16)!
        }
        
        return buffer
    }
    
    func asByteArrayEndian(_ length: Int)-> Array<UInt8> {
        var arrayLength :Int = self.utf16.count
        var hexString = self
        
        if arrayLength % 2 != 0 {
            hexString  = "0" + hexString
            arrayLength += 1
        }
        
        arrayLength = arrayLength / 2
        
        var buffer : Array<UInt8> = Array(repeating: 0 , count: length)
        for index :Int in 0  ..< arrayLength  {
            let substring :String = (hexString as NSString).substring(with: NSRange(location: 2 * index, length: 2))
            buffer[arrayLength - index - 1] = UInt8(substring, radix: 16)!
        }
        
        return buffer
    }
    
    func nemAddressNormalised() -> String {
        var newString = ""
        
        for i in stride(from: 0, to: self.characters.count, by: 6) {
            let substring = (self as NSString).substring(with: NSRange(location: i, length: ((self.characters.count - i) >= 6) ? 6 : self.characters.count - i))
            newString += substring + "-"
        }
        let length :Int = newString.characters.count - 1
        return (newString as NSString).substring(with: NSRange(location: 0, length: length))
    }
    
    func nemName() -> String {
//        let dataManager = CoreDataManager()
//        for wallet in dataManager.getWallets() {
//            let privateKey = HashManager.AES256Decrypt(wallet.privateKey, key: State.loadData!.password!)
//            let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey!)
//            
//            
//            if account_address == self {
//                return wallet.login
//            }
//        }
        
//        if AddressBookManager.isAllowed ?? false {
//            for contact in AddressBookManager.contacts {
//                for email in contact.emailAddresses{
//                    if email.label == "NEM" {
//                        let account_address = email.value as? String ?? " "
//                        if account_address == self {
//                            var resultName = contact.givenName ?? ""
//                            resultName = resultName + (contact.familyName == "" ? "" : " \(contact.familyName)")
//                            
//                            return resultName
//                        }
//                    }
//                }
//            }
//        }
        
        return self.nemAddressNormalised()
    }
    
    func nemKeyNormalized() -> String? {
        if Validate.key(self) {
            if self.asByteArray().count > 32 {
                return (self as NSString).substring(with: NSRange(location: 2, length: 64))
            } else {
                return self
            }
        } else {
            return nil
        }
    }
    
    func localized(_ defaultValue :String? = nil) -> String {
        return LocalizationManager.localizedSting(self, defaultValue: defaultValue) ?? self
    }
}
