//
//  AccountDataModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import SwiftyJSON

/// The meta data for an account.
public struct AccountData: SwiftyJSONMappable {
    
    // MARK: - Model Properties
    
    /// The title of the account.
    public var title: String?
    
    /// The address of the account.
    public var address: String!
    
    /// The public key of the account.
    public var publicKey: String!
    
    /// The current balance of the account.
    public var balance: Double!
    
    /// All cosignatories of the account.
    public var cosignatories: [AccountData]!
    
    /// All accounts for which the account acts as a cosignatory.
    public var cosignatoryOf: [AccountData]!
    
    // MARK: - Model Lifecycle
    
    public init?(jsonData: JSON) {
        
        if jsonData["meta"] == nil {
            address = jsonData["address"].stringValue
            publicKey = jsonData["publicKey"].stringValue
            balance = jsonData["balance"].doubleValue
            cosignatories = [AccountData]()
            cosignatoryOf = [AccountData]()
        } else {
            address = jsonData["account"]["address"].stringValue
            publicKey = jsonData["account"]["publicKey"].stringValue
            balance = jsonData["account"]["balance"].doubleValue
            cosignatories = try! jsonData["meta"]["cosignatories"].mapArray(AccountData)
            cosignatoryOf = try! jsonData["meta"]["cosignatoryOf"].mapArray(AccountData)
        }
    
        title = AccountManager.sharedInstance.titleForAccount(withAddress: address)
    }
}
