//
//  AccountDataModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import ObjectMapper

/// The meta data for an account.
struct AccountData: Mappable {
    
    // MARK: - Model Properties
    
    /// The current balance of the account.
    var balance: Double!
    
    /// All cosignatories of the account.
    var cosignatories: [NSDictionary]!
    
    /// All accounts for which the account acts as a cosignatory.
    var cosignatoryOf: [NSDictionary]!
    
    // MARK: - Model Lifecycle
    
    init?(_ map: Map) { }
    
    // MARK: - Model Helper Methods
    
    /// Maps the results from a network request to an account data object.
    mutating func mapping(map: Map) {
        
        balance <- map["account.balance"]
        cosignatories <- map["meta.cosignatories"]
        cosignatoryOf <- map["meta.cosignatoryOf"]
    }
}
