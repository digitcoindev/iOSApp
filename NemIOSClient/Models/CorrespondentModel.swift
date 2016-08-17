//
//  CorrespondentModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation

/// Represents a correspondent with whom some sort of transaction was performed.
class Correspondent {
    
    // MARK: - Model Properties
    
    /// The name of the correspondent if available.
    var name: String?
    
    /// The account address of the correspondent.
    var accountAddress: String!
    
    /// All transactions in conjunction with the correspondent.
    var transactions = [TransferTransaction]()
    
    /// The most recently performed transfer transaction.
    var mostRecentTransaction: TransferTransaction!
}
