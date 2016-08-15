//
//  MultisigTransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import ObjectMapper

///
class MultisigTransaction: Transaction {
    
    // MARK: - Model Properties
    
    var type = TransactionType.MultisigTransaction
    
    // MARK: - Model Lifecycle
    
    required init?(_ map: Map) { }
    
    // MARK: - Model Helper Methods
    
    /// Maps the results from a network request to a transaction object.
    func mapping(map: Map) {
        
//        balance <- map["account.balance"]
//        cosignatories <- map["meta.cosignatories"]
    }
}
