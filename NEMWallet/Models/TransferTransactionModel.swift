//
//  TransferTransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import Foundation
import SwiftyJSON

/** 
    Represents a transfer transaction on the NEM blockchain.
    Visit the [documentation](http://bob.nem.ninja/docs/#transferTransaction) for more information.
 */
final class TransferTransaction: Transaction {
    
    // MARK: - Model Properties
    
    /// The different transfer types for a transfer transaction.
    enum TransferType {
        case incoming
        case outgoing
    }
    
    /// The type of the transaction.
    var type = TransactionType.transferTransaction
    
    /// Additional information about the transaction.
    var metaData: TransactionMetaData?
    
    /// The version of the transaction.
    var version: Int!
    
    /// The number of seconds elapsed since the creation of the nemesis block.
    var timeStamp: Date!
    
    /// The amount of XEM that is transferred from sender to recipient.
    var amount: Double!
    
    ///
    var mosaics: [Mosaic]?
    
    /// The fee for the transaction.
    var fee: Double!
    
    /// The transfer type of the transaction.
    var transferType: TransferType!
    
    /// The address of the recipient.
    var recipient: String!
    
    /// The message of the transaction.
    var message: Message?
    
    /// The deadline of the transaction.
    var deadline: Int!
    
    /// The transaction signature.
    var signature: String!
    
    /// The public key of the account that created the transaction.
    var signer: String!
    
    // MARK: - Model Lifecycle
    
    required init?(version: Int, timeStamp: Date, amount: Double, fee: Double, recipient: String, message: Message?, deadline: Int, signer: String) {
        
        self.version = version
        self.timeStamp = timeStamp
        self.amount = amount
        self.fee = fee
        self.recipient = recipient
        self.message = message
        self.deadline = deadline
        self.signer = signer
    }
    
    required init?(jsonData: JSON) {
        
        metaData = try? jsonData["meta"].mapObject(TransactionMetaData.self)
        version = jsonData["transaction"]["version"].intValue
        timeStamp = Date(timeIntervalSince1970: jsonData["transaction"]["timeStamp"].doubleValue + Constants.genesisBlockTime)
        amount = jsonData["transaction"]["amount"].doubleValue / 1000000
        mosaics = try? jsonData["transaction"]["mosaics"].mapArray(Mosaic.self)
        fee = jsonData["transaction"]["fee"].doubleValue / 1000000
        recipient = jsonData["transaction"]["recipient"].stringValue
        deadline = jsonData["transaction"]["deadline"].intValue
        signature = jsonData["transaction"]["signature"].stringValue
        signer = jsonData["transaction"]["signer"].stringValue
        message = {
            var messageObject = try! jsonData["transaction"]["message"].mapObject(Message.self)
            if messageObject.payload != nil {
                if signer == AccountManager.sharedInstance.activeAccount?.publicKey {
                    fetchPublicKey(forCorrespondentWithAddress: recipient)
                    return messageObject
                } else {
                    messageObject.signer = signer
                    messageObject.getMessageFromPayload()
                    return messageObject
                }
            } else {
                return nil
            }
        }()
        transferType = {
            if recipient == AccountManager.sharedInstance.activeAccount?.address {
                return .incoming
            } else {
                return .outgoing
            }
        }()
        
        if let mosaics = mosaics {
            for mosaic in mosaics where mosaic.name == "xem" {
                self.mosaics!.remove(at: mosaics.index(where: { $0.name == mosaic.name })!)
            }
        }
        
        fetchMosaicDefinitions()
    }
    
    // MARK: - Model Helper Methods
    
    /**
         Fetches the public key for the transaction correspondent.
         This is needed to decrypt encrypted outgoing messages.
     
         - Parameter accountAddress: The account address of the correspondent for which the public key should get fetched.
     */
    private func fetchPublicKey(forCorrespondentWithAddress accountAddress: String) {
        
        NEMProvider.request(NEM.accountData(accountAddress: accountAddress)) { [weak self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    let accountData = try json.mapObject(AccountData.self)
                    
                    DispatchQueue.main.async {
                        
                        if self?.message?.payload != nil {
                            self!.message!.signer = accountData.publicKey
                            self!.message!.getMessageFromPayload()
                            NotificationCenter.default.post(name: Constants.transactionDataChangedNotification, object: nil)
                        }
                    }
                    
                } catch {
                    
                    DispatchQueue.main.async {
                        
                        print("Failure: \(response.statusCode)")
                    }
                }
                
            case let .failure(error):
                
                DispatchQueue.main.async {
                    
                    print(error)
                }
            }
        }
    }
    
    ///
    private func fetchMosaicDefinitions() {
        
        if let mosaics = mosaics {
            for mosaic in mosaics {
                NEMProvider.request(NEM.mosaicDefinition(namespace: mosaic.namespace)) { (result) in
                    
                    switch result {
                    case let .success(response):
                        
                        do {
                            let _ = try response.filterSuccessfulStatusCodes()
                            
                            let json = JSON(data: response.data)
                            let mosaicDefinitions = try json["data"].mapArray(MosaicDefinition.self)
                            
                            DispatchQueue.main.async {
                                
                                for mosaicDefinition in mosaicDefinitions where mosaicDefinition.name == mosaic.name {
                                    mosaic.quantity = mosaic.quantity / Double(truncating: pow(10, mosaicDefinition.divisibility) as NSNumber)
                                    NotificationCenter.default.post(name: Constants.transactionDataChangedNotification, object: nil)
                                }
                            }
                            
                        } catch {
                            
                            DispatchQueue.main.async {
                                
                                print("Failure: \(response.statusCode)")
                            }
                        }
                        
                    case let .failure(error):
                        
                        DispatchQueue.main.async {
                            
                            print(error)
                        }
                    }
                }
            }
        }
    }
}
