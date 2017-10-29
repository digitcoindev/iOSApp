//
//  InvoiceModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import CoreData

///
final class NewInvoice {
    
    // MARK: - Model Properties
    
    var recipient: String!
    var amount: Double!
    var message: String!
    
    // MARK: - Model Lifecycle
    
    required init?(recipient: String, amount: Double, message: String) {
        
        self.recipient = recipient
        self.amount = amount
        self.message = message
    }
}

/// Represents an invoice object.
open class Invoice: NSManagedObject {
    
    // MARK: - Model Properties
    
    /// The id of the invoice.
    @NSManaged var id: NSNumber
    
    /// The title of the recipient account.
    @NSManaged var accountTitle: String
    
    /// The address of the recipient account.
    @NSManaged var accountAddress: String
    
    /// The invoice amount.
    @NSManaged var amount: NSNumber
    
    /// The invoice message.
    @NSManaged var message: String
}
