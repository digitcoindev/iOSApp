//
//  TransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import ObjectMapper

enum TransactionType: Int {
    case TransferTransaction = 257
    case ImportanceTransferTransaction = 2049
    case MultisigTransaction = 4100
    case MultisigSignatureTransaction = 4098
    case MultisigAggregateModificationTransaction = 4097
}

///
protocol Transaction: Mappable {
    
    // MARK: - Model Properties
    
    /// The type of the transaction.
    var type: TransactionType { get }
    
    // MARK: - Model Lifecycle
    
    init?(_ map: Map)
    
    // MARK: - Model Helper Methods
    
    /// Maps the results from a network request to a transaction object.
    mutating func mapping(map: Map)
}
