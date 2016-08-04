//
//  AccountManager.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import CoreStore

/**
    The account manager singleton used to perform all kinds of actions
    in relationship with an account. Use this managers available methods 
    instead of writing your own logic.
 */
public class AccountManager {
    
    // MARK: - Manager Properties
    
    /// The singleton for the account manager.
    public static let sharedInstance = AccountManager()
    
    // MARK: - Manager Methods
    
    /**
        Fetches all stored accounts from the database.
     
        - Returns: An array of accounts ordered by index/position.
     */
    public func accounts() -> [Account] {
        
        let accounts = DatabaseManager.sharedInstance.dataStack.fetchAll(From(Account), OrderBy(.Descending("index"))) ?? []
        
        return accounts
    }
    
    public func createAccount() {
        
        DatabaseManager.sharedInstance.dataStack.beginAsynchronous { (transaction) -> Void in
            
            let account = transaction.create(Into(Account))
            account.title = "Konto"
            account.index = 1
            
            transaction.commit { (result) -> Void in
                switch result {
                case .Success(let _): print("success!")
                case .Failure(let error): print(error)
                }
            }
        }
    }
}
