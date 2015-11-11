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
                    let messageData = NSData(bytes: &(self.payload![1..<self.payload!.count]), length: self.payload!.count - 1)
                    return messageData.hexadecimalString() ?? "Could not decrypt"
                } else {
                    let messageData = NSData(bytes: &self.payload!, length: self.payload!.count)
                    return (NSString(data: messageData, encoding: NSUTF8StringEncoding) as? String) ?? "Could not decrypt"
                }
                
            case 2:
                let decryptedMessage = MessageCrypto.decrypt(self.payload!, recipientPrivateKey: HashManager.AES256Decrypt(State.currentWallet!.privateKey)
                    , senderPublicKey: self.signer!)
                return decryptedMessage
                
            default :
                return nil
            }
        } else {
            return nil
        }
    }
}
