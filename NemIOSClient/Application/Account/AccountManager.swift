//
//  AccountManager.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import CoreStore
import CryptoSwift

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
    public func create(account title: String, withPrivateKey privateKey: String? = nil, completion: (result: Result) -> Void) {
        
        DatabaseManager.sharedInstance.dataStack.beginAsynchronous { (transaction) -> Void in
            
            var privateKey = privateKey
            if privateKey == nil {
                privateKey = self.generatePrivateKey()
            }
            
            let encryptedPrivateKey = self.encryptPrivateKey(privateKey!)
            
            let account = transaction.create(Into(Account))
            account.title = title
            account.publicKey = self.generatePublicKey(forPrivateKey: privateKey!)
            account.privateKey = encryptedPrivateKey
            account.address = self.generateAddress(forPublicKey: account.publicKey)
            account.position = self.positionForNewAccount()
            
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
    public func delete(account account: Account) {
        
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
    
    /**
        Searches for the title of an account with the provided account
        address. The account with the provided account address could already
        be present in the app or saved inside the address book.
     
        - Parameter accountAddress: The account address for which the account title should get fetched.
     
        - Returns: The title of the account with the provided account address. If no title was found the method will return nil.
     */
    public func titleForAccount(withAddress accountAddress: String) -> String? {
        
        let accounts = self.accounts()
        
        for account in accounts where account.address == accountAddress {
            return account.title
        }
        
        return nil
    }
    
    /**
        Validates if an account with the provided private key already
        got added to the application or not.
     
        - Parameter privateKey: The private key of the account that should get checked for existence.
     
        - Throws:
            - AccountImportValidation.AccountAlreadyPresent if an account with the provided private key already got added to the application.
     
        - Returns: A bool indicating that no account with the provided private key was added to the application.
     */
    public func validateAccountExistence(forAccountWithPrivateKey privateKey: String) throws -> Bool {
        
        let accounts = self.accounts()
        
        for account in accounts {
            let accountPrivateKey = decryptPrivateKey(account.privateKey)
            if privateKey == accountPrivateKey {
                throw AccountImportValidation.AccountAlreadyPresent(accountTitle: account.title)
            }
        }
        
        return true
    }
    
    /**
        Validates a provided key (private key or public key) and checks
        if the key is made up of valid characters.
     
        - Parameter key: The key that shoud get validated.
        - Parameter length: The lenght of the key - will use the default length of 64 characters if this parameter isn't provided.
     
        - Returns: A bool indicating whether the key is valid or not.
     */
    public func validateKey(key: String, length: Int = 64) -> Bool {

        let validator = Array<UInt8>("0123456789abcdef".utf8)
        var keyArray = Array<UInt8>(key.utf8)
        
        if keyArray.count == length || keyArray.count == length + 2 {
            if keyArray.count == length + 2 {
                keyArray.removeAtIndex(0)
                keyArray.removeAtIndex(0)
            }
            
            for value in keyArray {
                var find = false
                for valueChecker in validator where valueChecker == value {
                    find = true
                    break
                }
                
                if !find {
                    return false
                }
            }
            
        } else {
            return false
        }
        
        return true
    }
    
    /**
        Generates the address for the provided public key.
     
        - Parameter publicKey: The public key for which the address should get generated.
     
        - Returns: The generated address as a string.
     */
    public func generateAddress(forPublicKey publicKey: String) -> String {
        
        var inBuffer = publicKey.asByteArray()
        var stepOneSHA256: Array<UInt8> = Array(count: 64, repeatedValue: 0)
        
        SHA256_hash(&stepOneSHA256, &inBuffer, 32)
        
        let stepOneSHA256Text = NSString(bytes: stepOneSHA256, length: stepOneSHA256.count, encoding: NSUTF8StringEncoding) as! String
        let stepTwoRIPEMD160Text = RIPEMD.hexStringDigest(stepOneSHA256Text) as String
        let stepTwoRIPEMD160Buffer = stepTwoRIPEMD160Text.asByteArray()
        
        var version = Array<UInt8>()
        version.append(network)
        
        var stepThreeVersionPrefixedRipemd160Buffer = version + stepTwoRIPEMD160Buffer
        var checksumHash: Array<UInt8> = Array(count: 64, repeatedValue: 0)
        
        SHA256_hash(&checksumHash, &stepThreeVersionPrefixedRipemd160Buffer, 21)
        
        let checksumText = NSString(bytes: checksumHash, length: checksumHash.count, encoding: NSUTF8StringEncoding) as! String
        var checksumBuffer = checksumText.asByteArray()
        var checksum = Array<UInt8>()
        checksum.append(checksumBuffer[0])
        checksum.append(checksumBuffer[1])
        checksum.append(checksumBuffer[2])
        checksum.append(checksumBuffer[3])
        
        let stepFourResultBuffer = stepThreeVersionPrefixedRipemd160Buffer + checksum
        let address = Base32Encode(NSData(bytes: stepFourResultBuffer, length: stepFourResultBuffer.count))
        
        return address
    }
    
    /**
        Generates the address for the provided private key.
     
        - Parameter privateKey: The private key for which the address should get generated.
     
        - Returns: The generated address as a string.
     */
    public func generateAddress(forPrivateKey privateKey: String) -> String {
        
        let publicKey = generatePublicKey(forPrivateKey: privateKey)
        return generateAddress(forPublicKey: publicKey)
    }
    
    /**
        Decrypts the provided encrypted private key with the application password.
     
        - Parameter encryptedPrivateKey: The encrypted private key that should get decrypted.
     
        - Returns: The decrypted private key as a string.
     */
    public func decryptPrivateKey(encryptedPrivateKey: String) -> String {
        
        let encryptedApplicationPassword = "ebd7071cc325d111e12464f63712b8010552a1f29b5afa721fbfea34d37762bf"
        let privateKey = HashManager.AES256Decrypt(encryptedPrivateKey, key: encryptedApplicationPassword)
        
        return privateKey!
    }
    
    // MARK: - Private Manager Methods
    
    /**
        Determines the position for a new account.
     
        - Returns: The position for a new account in the account list as an integer.
     */
    private func positionForNewAccount() -> Int {
        
        if let maxPosition = DatabaseManager.sharedInstance.dataStack.queryValue(From(Account), Select<Int>(.Maximum("position"))) {
            if (maxPosition == 0) {
                return maxPosition
            } else {
                return maxPosition + 1
            }
        } else {
            return 0
        }
    }
    
    /// Generates a new and unique private key.
    private func generatePrivateKey() -> String {
        
        var privateKeyBytes: Array<UInt8> = Array(count: 32, repeatedValue: 0)
        createPrivateKey(&privateKeyBytes)
        
        let privateKey: String = NSData(bytes: &privateKeyBytes, length: 32).toHexString()
        
        return privateKey.nemKeyNormalized()!
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
        
        return publicKey.nemKeyNormalized()!
    }
    
    /**
        Encrypts the provided private key with the application password.
        
        - Parameter privateKey: The private key that should get encrypted.
     
        - Returns: The encrypted private key as a string.
     */
    private func encryptPrivateKey(privateKey: String) -> String {
        
        let encryptedApplicationPassword = NSData(bytes: "ebd7071cc325d111e12464f63712b8010552a1f29b5afa721fbfea34d37762bf".asByteArray())
        let encryptedPrivateKey = HashManager.AES256Encrypt(privateKey, key: encryptedApplicationPassword.toHexString())
        
        return encryptedPrivateKey
    }
}
