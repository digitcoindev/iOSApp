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
    
    // MARK: - Public Manager Methods
    
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
     
        - Returns: The result of the operation - success or failure.
     */
    public func create(account title: String, completion: (result: Result) -> Void) {
        
        DatabaseManager.sharedInstance.dataStack.beginAsynchronous { (transaction) -> Void in
            
            let privateKey = self.generatePrivateKey()
            let privateKeyHash = self.createHash(forPrivateKey: privateKey)
            
            let account = transaction.create(Into(Account))
            account.title = title
            account.position = self.maxPosition() + 1
            account.privateKey = privateKeyHash
            
            transaction.commit { (result) -> Void in
                switch result {
                case .Success( _):
                    return completion(result: .Success)
                    
                case .Failure( _):
                    return completion(result: .Failure)
                }
            }
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
        Updates the saved title/name for an account in the database.
     
        - Parameter account: The existing account that should get updated.
        - Parameter title: The new title for the account that should get updated.
     */
    public func updateTitle(forAccount account: Account, withNewTitle title: String) {
        
        DatabaseManager.sharedInstance.dataStack.beginAsynchronous { (transaction) -> Void in
            
            let editableAccount = transaction.edit(account)!
            editableAccount.title = title
            
            transaction.commit()
        }
    }
    
    // MARK: - Private Manager Methods
    
    /**
        Fetches the position for the last account in the account list.
     
        - Returns: The position of the last account in the account list as an integer.
     */
    private func maxPosition() -> Int {
        
        let maxPosition = DatabaseManager.sharedInstance.dataStack.queryValue(From(Account), Select<Int>(.Maximum("position")))
        
        return maxPosition!
    }
    
    /// Generates a new and unique private key.
    private func generatePrivateKey() -> String {
        
        var privateKeyBytes: Array<UInt8> = Array(count: 32, repeatedValue: 0)
        createPrivateKey(&privateKeyBytes)
        
        let privateKey: String = NSData(bytes: &privateKeyBytes, length: 32).toHexString()
        
        return privateKey
    }
    
    /**
        Generates the public key for the provided private key.
     
        - Parameter privateKey: The private key for which the public key should get generated.
     
        - Returns: The generated public key as a string.
     */
    private func generatePublicKey(forPrivateKey privateKey: String) -> String {
        
        var publicKeyBytes: Array<UInt8> = Array(count: 32, repeatedValue: 0)
        var privateKeyBytes: Array<UInt8> = privateKey.asByteArrayEndian(privateKey.asByteArray().count)
        createPublicKey(&publicKeyBytes, &privateKeyBytes)
        
        let publicKey: String = NSData(bytes: &publicKeyBytes, length: 32).toHexString()
        
        return publicKey
    }
    
    /**
        Creates a hash from the provided private key and application password.
        
        - Parameter privateKey: The private key that should get hashed.
     
        - Returns: The hashed private key as a string.
     */
    private func createHash(forPrivateKey privateKey: String) -> String {
        
        let passwordHash = NSData(bytes: "1234".asByteArray())
        let privateKeyHash = HashManager.AES256Encrypt(privateKey, key: passwordHash.toHexString())
        
        return privateKeyHash
    }
}
