//
//  CorrespondentModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation

/// Represents a correspondent with whom some sort of transaction was performed.
public class Correspondent {
    
    // MARK: - Model Properties
    
    /// The name of the correspondent if available.
    public var name: String?
    
    /// The account address of the correspondent.
    public var accountAddress: String!
    
    /// The public key of the correspondent.
    public var accountPublicKey: String?
    
    /// All transactions in conjunction with the correspondent.
    public var transactions = [Transaction]()
    
    /// All unconfirmed transactions in conjunction with the correspondent.
    public var unconfirmedTransactions = [Transaction]()
    
    /// The most recently performed transfer transaction.
    public var mostRecentTransaction: Transaction!
}
