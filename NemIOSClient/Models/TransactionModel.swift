//
//  TransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import ObjectMapper
import SwiftyJSON

/// All available transaction types on the NEM blockchain.
enum TransactionType: Int {
    case TransferTransaction = 257
    case ImportanceTransferTransaction = 2049
    case MultisigTransaction = 4100
    case MultisigSignatureTransaction = 4098
    case MultisigAggregateModificationTransaction = 4097
}

/// Represents a transaction on the NEM blockchain.
protocol Transaction: Mappable, SwiftyJSONMappable {
    
    // MARK: - Model Properties
    
    /// The type of the transaction.
    var type: TransactionType { get }
    
    /// The number of seconds elapsed since the creation of the nemesis block.
    var timeStamp: Int! { get set }
    
    /// The fee for the transaction.
    var fee: Int! { get set }
    
    /// The deadline of the transaction.
    var deadline: Int! { get set }
    
    /// The transaction signature.
    var signature: String! { get set }
    
    /// The public key of the account that created the transaction.
    var signer: String! { get set }
    
    // MARK: - Model Lifecycle
    
    init?(_ map: Map)
    
    init?(jsonData: JSON)
    
    // MARK: - Model Helper Methods
    
    /// Maps the results from a network response to a transaction object.
    mutating func mapping(map: Map)
}
