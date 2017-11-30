//
//  MosaicDefinitionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import Foundation
import SwiftyJSON

///
final class MosaicDefinition: SwiftyJSONMappable {
    
    // MARK: - Model Properties
    
    /// The name of the asset definition.
    var name: String!
    
    /// The mosaic description.
    var description: String!
    
    /// The namespace of the asset.
    var namespace: String!
    
    /// Defines the smallest sub-unit that a mosaic can be divided into.
    var divisibility: Int!
    
    /// Defines how many units of the mosaic are initially created.
    var initialSupply: Double!
    
    /// Determines whether or not the supply can be changed by the creator at a later point.
    var supplyIsMutable: Bool!
    
    /// Determines whether or not the a mosaic can be transferred to a user other than the creator.
    var isTransferable: Bool!
    
    /// The public key of the mosaic definition creator.
    var creator: String!
    
    
    // MARK: - Model Lifecycle
    
    public required init?(jsonData: JSON) {
        
        var jsonData = jsonData
        if jsonData["meta"]["id"].int != nil {
            jsonData = jsonData["mosaic"]
        }
        
        name = jsonData["id"]["name"].stringValue
        description = jsonData["description"].stringValue
        namespace = jsonData["id"]["namespaceId"].stringValue
        divisibility = jsonData["properties"][0]["value"].intValue
        initialSupply = jsonData["properties"][1]["value"].doubleValue
        supplyIsMutable = jsonData["properties"][2]["value"].boolValue
        isTransferable = jsonData["properties"][3]["value"].boolValue
        creator = jsonData["creator"].stringValue
    }
}
