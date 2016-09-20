//
//  MessageModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import SwiftyJSON

/// All available message types.
public enum MessageType: Int {
    case unencrypted = 1
    case encrypted = 2
}

/// Represents a transaction message on the NEM blockchain.
public struct Message: SwiftyJSONMappable {
    
    // MARK: - Model Properties
    
    /// The type of the message.
    public var type: MessageType
    
    /// The payload is the actual (possibly encrypted) message data.
    public var payload: [UInt8]!
    
    /// The message payload (data) as a readable string.
    public var message: String?
    
    // The public key of the account that created the transaction.
    public var signer: String?
    
    public var encryptedPrivateKey: String?
    
    // MARK: - Model Lifecycle
    
    public init?(type: MessageType, payload: [UInt8], message: String?) {
        
        self.type = type
        self.payload = payload
        self.message = message
    }
    
    public init?(jsonData: JSON) {

        type = MessageType(rawValue: jsonData["type"].intValue) ?? MessageType.unencrypted
        payload = jsonData["payload"].string?.asByteArray()
        message = {
            guard payload != nil else { return String() }

            switch type {
            case .unencrypted:
                if payload!.first == UInt8(0xfe) {
                    print("HMMMM")
                    var bytes = self.payload!
                    bytes.removeFirst()
                    return String(bytes: bytes, encoding: String.Encoding.utf8)
                } else {
                    return String(bytes: payload!, encoding: String.Encoding.utf8)
                }
                
            case MessageType.encrypted:
                guard signer != nil else { return String() }
                let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
                let decryptedMessage: String? = TransactionManager.sharedInstance.decryptMessage(self.payload!, recipientEncryptedPrivateKey: privateKey!, senderPublicKey: signer!)
                
                return decryptedMessage
            }
        }()
    }
}
