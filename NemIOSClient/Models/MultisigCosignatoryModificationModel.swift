//
//  MultisigCosignatoryModificationModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation

/// The type of modification.
public enum ModificationType: Int {
    case addCosignatory = 1
    case deleteCosignatory = 2
}

/**
    Represents a multisig cosignatory modification on the NEM blockchain.
    Visit the [documentation](http://bob.nem.ninja/docs/#multisigCosignatoryModification)
    for more information.
 */
public struct MultisigCosignatoryModification {
    
    // MARK: - Model Properties
    
    /// The type of modification.
    public var modificationType: ModificationType!
    
    /// The public key of the cosignatory account.
    public var cosignatoryAccount: String!
    
    // MARK: - Model Lifecycle
    
    public init?(modificationType: ModificationType, cosignatoryAccount: String) {
        
        self.modificationType = modificationType
        self.cosignatoryAccount = cosignatoryAccount
    }
}
