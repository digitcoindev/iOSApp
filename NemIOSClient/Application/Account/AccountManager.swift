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
     
        - Returns: An array of accounts ordered by position (ascending).
     */
    public func accounts() -> [Account] {
        
        let accounts = DatabaseManager.sharedInstance.dataStack.fetchAll(From(Account), OrderBy(.Ascending("position"))) ?? []
        
        return accounts
    }
    
    /**
        Creates a new account object and stores that object in the database.
     
        - Parameter title: The title/name of the new account.
     */
    public func create(account title: String) {
        
        DatabaseManager.sharedInstance.dataStack.beginAsynchronous { (transaction) -> Void in
            
            let account = transaction.create(Into(Account))
            account.title = title
            account.position = self.maxPosition() + 1
            
            transaction.commit()
        }
    }
    
    /**
        Deletes the provided account object from the database and updates the
        position of all other accounts accordingly.
        
        - Parameter account: The account object that should get deleted.
     */
    public func delete(account: Account) {
        
        var accounts = self.accounts()
        accounts.removeAtIndex(account.position)
        
        updatePosition(forAccounts: accounts)
        
        DatabaseManager.sharedInstance.dataStack.beginAsynchronous { (transaction) -> Void in
            
            transaction.delete(account)
            transaction.commit()
        }
    }
    
    /**
        Stores an account move from the account list in the database by updating 
        the position for all accounts.
     
        - Parameter accounts: An array of all accounts in their state after the move (with their new indexPath).
     */
    public func updatePosition(forAccounts accounts: [Account]) {
        
        DatabaseManager.sharedInstance.dataStack.beginAsynchronous { (transaction) -> Void in
            
            for account in accounts {
                let editableAccount = transaction.edit(account)!
                editableAccount.position = accounts.indexOf(account)!
            }
            
            transaction.commit()
        }
    }
    
    /**
        Fetches the position for the last account in the account list.
     
        - Returns: The position of the last account in the account list as an integer.
     */
    private func maxPosition() -> Int {
        
        let maxPosition = DatabaseManager.sharedInstance.dataStack.queryValue(From(Account), Select<Int>(.Maximum("position")))
        
        return maxPosition!
    }
}
