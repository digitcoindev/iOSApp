import UIKit

class MessageGetMetaData: NSObject
{
    private var _payload :[UInt8]?
    var payload :[UInt8]? {
        get {
            return _payload
        }
        set {
            _payload = newValue
        }
    }
    
    var type :Int!
    var signer :String? = nil
    
    final func getMessageString()-> String? {
        
        if self.payload != nil {
            switch self.type {
            case 1:
                if self.payload!.first == UInt8(0xfe) {
                    var bytes = self.payload!
                    bytes.removeFirst()
                    
                    return bytes.toHexString()
                } else {
                    let messageData = NSData(bytes: &self.payload!, length: self.payload!.count)
                    return (NSString(data: messageData, encoding: NSUTF8StringEncoding) as? String)
                }
                
            case 2:
                guard let signer = self.signer else {return nil}
                let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
                let decryptedMessage :String? = MessageCrypto.decrypt(self.payload!, recipientPrivateKey: privateKey!
                    , senderPublicKey: signer)
                
                return decryptedMessage
            default :
                return nil
            }
        } else {
            return ""
        }
    }
}
