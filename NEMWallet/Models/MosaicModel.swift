//
//  MosaicModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import Foundation
import SwiftyJSON

///
final class Mosaic: SwiftyJSONMappable {
    
    // MARK: - Model Properties
    
    /// The name of the mosaic.
    var name: String!
    
    /// The mosaic description.
    var description: String!
    
    /// The namespace of the mosaic.
    var namespace: String!
    
    /// The transaction quantity.
    var quantity: Int!
    
    // MARK: - Model Lifecycle
    
    public required init?(jsonData: JSON) {
        
        name = jsonData["mosaicId"]["name"].stringValue
        namespace = jsonData["mosaicId"]["namespaceId"].stringValue
        quantity = jsonData["quantity"].intValue
    }
}
