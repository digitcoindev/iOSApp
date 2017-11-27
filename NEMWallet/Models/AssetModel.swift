//
//  AssetModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import Foundation
import SwiftyJSON

///
final class Asset: SwiftyJSONMappable {
    
    // MARK: - Model Properties
    
    ///
    public var name: String!
    
    ///
    public var namespace: String!
    
    ///
    public var quantity: Int!
    
    // MARK: - Model Lifecycle
    
    public required init?(jsonData: JSON) {
        
        name = jsonData["mosaicId"]["name"].stringValue
        namespace = jsonData["mosaicId"]["namespaceId"].stringValue
        quantity = jsonData["quantity"].intValue
    }
}
