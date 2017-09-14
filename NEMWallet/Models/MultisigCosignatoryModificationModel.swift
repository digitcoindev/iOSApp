//
//  MultisigCosignatoryModificationModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import Foundation
import SwiftyJSON

/// The type of modification.
enum ModificationType: Int {
    case addCosignatory = 1
    case deleteCosignatory = 2
}

/**
    Represents a multisig cosignatory modification on the NEM blockchain.
    Visit the [documentation](http://bob.nem.ninja/docs/#multisigCosignatoryModification) for more information.
 */
struct MultisigCosignatoryModification: SwiftyJSONMappable {
    
    // MARK: - Model Properties
    
    /// The type of modification.
    var modificationType: ModificationType!
    
    /// The public key of the cosignatory account.
    var cosignatoryAccount: String!
    
    /// The length of the modificatoin structure.
    var modificationStructureLength = 40
    
    /// The length of the cosignatory public key.
    var cosignatoryPublicKeyLength = 32
    
    // MARK: - Model Lifecycle
    
    init?(modificationType: ModificationType, cosignatoryAccount: String) {
        
        self.modificationType = modificationType
        self.cosignatoryAccount = cosignatoryAccount
    }
    
    init?(jsonData: JSON) {
        
        modificationType = ModificationType(rawValue: jsonData["modificationType"].intValue)
        cosignatoryAccount = jsonData["cosignatoryAccount"].stringValue
    }
}
