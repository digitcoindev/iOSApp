//
//  AccountModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import CoreData

/// Represents an account object.
public class Account: NSManagedObject {
    
    // MARK: - Model Properties
    
    /// The title of the account.
    @NSManaged var title: String
    
    /// The index/position of the account chosen by the user.
    @NSManaged var index: Int
}
