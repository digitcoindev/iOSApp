//
//  TransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import Foundation
import SwiftyJSON

/// All available transaction types on the NEM blockchain.
enum TransactionType: Int {
    case transferTransaction = 257
    case importanceTransferTransaction = 2049
    case provisionNamespaceTransaction = 8193
    case multisigTransaction = 4100
    case multisigSignatureTransaction = 4098
    case multisigAggregateModificationTransaction = 4097
}

/// Represents a transaction on the NEM blockchain.
protocol Transaction: SwiftyJSONMappable {
    
    // MARK: - Model Properties
    
    /// The type of the transaction.
    var type: TransactionType { get }
    
    /// The version of the transaction.
    var version: Int! { get set }
    
    /// The number of seconds elapsed since the creation of the nemesis block.
    var timeStamp: Date! { get set }
    
    /// The fee for the transaction.
    var fee: Double! { get set }
    
    /// The deadline of the transaction.
    var deadline: Int! { get set }
    
    /// The transaction signature.
    var signature: String! { get set }
    
    /// The public key of the account that created the transaction.
    var signer: String! { get set }
    
    // MARK: - Model Lifecycle
    
    init?(jsonData: JSON)
}
