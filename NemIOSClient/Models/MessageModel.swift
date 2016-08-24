//
//  MessageModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import SwiftyJSON

/// All available message types.
enum MessageType: Int {
    case Unencrypted = 1
    case Encrypted = 2
}

/// Represents a transaction message on the NEM blockchain.
struct Message: SwiftyJSONMappable {
    
    // MARK: - Model Properties
    
    /// The type of the message.
    var type: MessageType
    
    /// The payload is the actual (possibly encrypted) message data.
    var payload: String!
    
    /// The message payload (data) as a readable string.
    var message: String!
    
    // The public key of the account that created the transaction.
    var signer: String!
    
    var encryptedPrivateKey: String!
    
    // MARK: - Model Lifecycle
    
    init?(jsonData: JSON) {

        type = MessageType(rawValue: jsonData["type"].intValue) ?? MessageType.Unencrypted
        payload = jsonData["payload"].string
        message = {
            guard payload != nil else { return String() }

            switch type {
            case .Unencrypted:
                if payload!.asByteArray().first == UInt8(0xfe) {
                    print("HMMMM")
                    var bytes = self.payload!.asByteArray()
                    bytes.removeFirst()
                    return String(bytes: bytes, encoding: NSUTF8StringEncoding)
                } else {
                    return String(bytes: payload!.asByteArray(), encoding: NSUTF8StringEncoding)
                }
                
            case MessageType.Encrypted:
                guard signer != nil else { return String() }
                let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
                let decryptedMessage :String? = MessageCrypto.decrypt(self.payload!.asByteArray(), recipientPrivateKey: privateKey!
                    , senderPublicKey: signer)
                
                return decryptedMessage
            }
        }()
    }
}
