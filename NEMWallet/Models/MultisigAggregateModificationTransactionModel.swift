//
//  MultisigAggregateModificationTransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import Foundation
import SwiftyJSON

/**
    Represents a multisig aggregate modification transaction on the NEM blockchain.
    Visit the [documentation](http://bob.nem.ninja/docs/#multisigAggregateModificationTransaction) for more information.
 */
final class MultisigAggregateModificationTransaction: Transaction {
    
    // MARK: - Model Properties
    
    /// The type of the transaction.
    var type = TransactionType.multisigAggregateModificationTransaction
    
    /// Additional information about the transaction.
    var metaData: TransactionMetaData?
    
    /// The version of the transaction.
    var version: Int!
    
    /// The number of seconds elapsed since the creation of the nemesis block.
    var timeStamp: Date!
    
    /// The fee for the transaction.
    var fee: Double!
    
    /// The array of multisig modifications.
    var modifications = [MultisigCosignatoryModification]()
    
    /// Value indicating the relative change of the minimum cosignatories.
    var relativeChange: Int!
    
    /// The deadline of the transaction.
    var deadline: Int!
    
    /// The transaction signature.
    var signature: String!
    
    /// The public key of the account that created the transaction.
    var signer: String!
    
    // MARK: - Model Lifecycle
    
    required init?(version: Int, timeStamp: Date, fee: Double, relativeChange: Int, deadline: Int, signer: String) {
        
        self.version = version
        self.timeStamp = timeStamp
        self.fee = fee
        self.relativeChange = relativeChange
        self.deadline = deadline
        self.signer = signer
    }
    
    required init?(jsonData: JSON) {
        
        metaData = try? jsonData["meta"].mapObject(TransactionMetaData.self)
        version = jsonData["transaction"]["version"].intValue
        timeStamp = Date(timeIntervalSince1970: jsonData["transaction"]["timeStamp"].doubleValue + Constants.genesisBlockTime)
        fee = jsonData["transaction"]["fee"].doubleValue / 1000000
        deadline = jsonData["transaction"]["deadline"].intValue
        signature = jsonData["transaction"]["signature"].stringValue
        signer = jsonData["transaction"]["signer"].stringValue
        modifications = try! jsonData["transaction"]["modifications"].mapArray(MultisigCosignatoryModification.self)
    }
    
    // MARK: - Model Helper Methods
    
    func addModification(_ modificationType: ModificationType, cosignatoryAccount: String) {
        
        let modification = MultisigCosignatoryModification(modificationType: modificationType, cosignatoryAccount: cosignatoryAccount)
        self.modifications.append(modification!)
    }
}
