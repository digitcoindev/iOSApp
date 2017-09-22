//
//  AccountListViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import CryptoSwift
import KeychainSwift

/**
    The account list view controller that shows a list with all available
    accounts which lets the user choose an account to further inspect.
 */
class AccountListViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    /// All accounts that will get listed in the table view.
    var accounts = [Account]()
    
    fileprivate var refreshTimer: Timer? = nil
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addAccountButton: UIButton!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accounts = AccountManager.sharedInstance.accounts()
        
//
//        let encryptedPrivateKey = accounts[0].privateKey
//        let privateKey = "0c2fddad5a6a8eeed238c66ff17dc42f60f63b771528983ee5114a47bb610d44"
//        let applicationPassword = SettingsManager.sharedInstance.applicationPassword()
//        let randomSalt = SettingsManager.sharedInstance.authenticationSalt()
//        print("\n\(accounts[0].title) -> Private Key \(privateKey)")
//        print("Encrypted Private Key: \(encryptedPrivateKey)")
//        print("Application Password: \(applicationPassword)")
//        print("Random Salt: \(randomSalt)")
//
//        // Correct Encrypting
//
//        let messageBytes = privateKey.asByteArray()
//        var messageData = NSData(bytes: messageBytes, length: messageBytes.count)
//        let ivData = NSData().generateRandomIV(16)
//        messageData = messageData.aesEncrypt(key: applicationPassword.asByteArray(), iv: ivData!.bytes)!
//        let reconstructedEncryptedPrivateKey = ivData!.bytes.toHexString() + messageData.toHexString()
//
//        print("\nReconstructed Encrypted Private Key: \(reconstructedEncryptedPrivateKey) - \(reconstructedEncryptedPrivateKey.asByteArray().count)")
//
//        // Correct Decrypting
//
//        let inputBytes = reconstructedEncryptedPrivateKey.asByteArray()
//        let customizedIV =  Array(inputBytes[0..<16])
//        let encryptedBytes = Array(inputBytes[16..<inputBytes.count])
//        var data :NSData? = NSData(bytes: encryptedBytes, length: encryptedBytes.count)
//        data = data!.aesDecrypt(key: applicationPassword.asByteArray(), iv: customizedIV)
//        let reconstructedDecryptedPrivateKey = data!.toHexString()
//
//        print("Reconstructed Decrypted Private Key: \(reconstructedDecryptedPrivateKey) - \(reconstructedDecryptedPrivateKey.asByteArray().count)")
//
//        // Faulty Encrypting
//
////        var okey = Array("hallo".utf8)
//        var okey = "12312a".asByteArray()
//        var key = "12312a".asByteArray()
//
//        let keychain = KeychainSwift()
//        keychain.set("12312a", forKey: "applicationPassword")
//        let _applicationPassword = keychain.get("applicationPassword") ?? String()
//        print(_applicationPassword)
//
//        print("\n -- OKEY: \(okey.toHexString()) - \(okey.count)")
//
//        let fmessageBytes = privateKey.asByteArray()
//        var fmessageData = NSData(bytes: fmessageBytes, length: fmessageBytes.count)
//        let fivData = NSData().generateRandomIV(16)
//        fmessageData = fmessageData.aesEncrypt(key: okey, iv: fivData!.bytes)!
////        fmessageData = fmessageData.aesEncrypt(key: Array("hallotesthallotesthallotest".utf8), iv: fivData!.bytes)!
//        let freconstructedEncryptedPrivateKey = fivData!.bytes.toHexString() + fmessageData.toHexString()
//
//        print("\nFaulty Reconstructed Encrypted Private Key: \(freconstructedEncryptedPrivateKey) - \(freconstructedEncryptedPrivateKey.asByteArray().count)")
//
//        // Faulty Decrypting
//
////        let fapplicationPasswordHash = try! HashManager.generateAesKeyForString("123123", salt: newSaltData, roundCount: 2000)!
//
//        let finputBytes = freconstructedEncryptedPrivateKey.asByteArray()
//        let fcustomizedIV =  Array(finputBytes[0..<16])
//        let fencryptedBytes = Array(finputBytes[16..<finputBytes.count])
//        var fdata :NSData? = NSData(bytes: fencryptedBytes, length: fencryptedBytes.count)
//        fdata = fdata!.aesDecrypt(key: key, iv: fcustomizedIV)
//        let freconstructedDecryptedPrivateKey = fdata!.toHexString()
//
//        print("Faulty Reconstructed Decrypted Private Key: \(freconstructedDecryptedPrivateKey) - \(freconstructedDecryptedPrivateKey.asByteArray().count)")
//
//        // Another Decrypting Try
//
//        do {
//            let aes = try AES(key: key, iv: fcustomizedIV, blockMode: .CBC, padding: PKCS7())
////            let aes = try AES(key: "passwordpassword", iv: "drowssapdrowssap", ) // aes128
//            let ciphertext = try aes.decrypt(fencryptedBytes).toHexString()
//
//            print("Another Faulty Reconstructed Decrypted Private Key: \(ciphertext) - \(ciphertext.asByteArray().count)")
//
//            let aes1 = try AES(key: okey, iv: fcustomizedIV, blockMode: .CBC, padding: PKCS7())
//            //            let aes = try AES(key: "passwordpassword", iv: "drowssapdrowssap", ) // aes128
//            let ciphertext1 = try aes1.decrypt(fencryptedBytes).toHexString()
//
//            print("Another Faulty Reconstructed Decrypted Private Key: \(ciphertext1) - \(ciphertext1.asByteArray().count)")
//
//        } catch { }

        
        updateViewControllerAppearance()
        createEditButtonItemIfNeeded()
        startRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (tableView.indexPathForSelectedRow != nil) {
            let indexPath = tableView.indexPathForSelectedRow!
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    /// Needed for a smooth appearance of the alert view controller.
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    /// Needed for a smooth appearance of the alert view controller.
    override var canResignFirstResponder: Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "showAccountDetailTabBarController":
            
            if let indexPath = tableView.indexPathForSelectedRow {
                AccountManager.sharedInstance.activeAccount = accounts[indexPath.row]
            }
            
        default:
            return
        }
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller.
    fileprivate func updateViewControllerAppearance() {
        
        navigationItem.title = "ACCOUNTS".localized()
        addAccountButton.setTitle("ADD_ACCOUNT".localized(), for: UIControlState())
        addAccountButton.setImage(#imageLiteral(resourceName: "Add").imageWithColor(UIColor(red: 90.0/255.0, green: 179.0/255.0, blue: 232.0/255.0, alpha: 1)), for: UIControlState())
        addAccountButton.imageView!.contentMode = UIViewContentMode.scaleAspectFit
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    /**
        Checks if there are any accounts to show and creates an edit button
        item on the right of the navigation bar if that's the case.
     */
    fileprivate func createEditButtonItemIfNeeded() {
        
        if (accounts.count > 0) {
            navigationItem.rightBarButtonItem = editButtonItem
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    /// Starts refreshing the network time in the defined interval.
    fileprivate func startRefreshing() {
        
        refreshTimer = Timer.scheduledTimer(timeInterval: TimeInterval(updateInterval), target: self, selector: #selector(AccountListViewController.refreshNetworkTime), userInfo: nil, repeats: true)
    }
    
    /// Stops refreshing the network time.
    fileprivate func stopRefreshing() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    /// Synchronizes the application time with the network time.
    open func refreshNetworkTime() {
        
        TimeManager.sharedInstance.synchronizeTime()
    }
    
    /**
        Asks the user for confirmation of the deletion of an account and deletes 
        the account accordingly from both the table view and the database.
     
        - Parameter indexPath: The index path of the account that should get removed and deleted.
     */
    fileprivate func deleteAccount(atIndexPath indexPath: IndexPath) {
        
        let account = accounts[indexPath.row]
        
        let accountDeletionAlert = UIAlertController(title: "INFO".localized(), message: String(format: "DELETE_CONFIRMATION_MASSAGE_ACCOUNTS".localized(), account.title), preferredStyle: .alert)
        
        accountDeletionAlert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: nil))
        
        accountDeletionAlert.addAction(UIAlertAction(title: "OK".localized(), style: .destructive, handler: { [unowned self] (action) in
            
            self.accounts.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .bottom)
            self.createEditButtonItemIfNeeded()
            
            AccountManager.sharedInstance.delete(account: account)
        }))
        
        present(accountDeletionAlert, animated: true, completion: nil)
    }
    
    /**
        Moves an account from its previous position in the array to the new position
        and saves that change in the database.
     
        - Parameter sourceIndexPath: The previous index path of the account (before the move).
        - Parameter destinationIndexPath: The new index path of the account (after the move)
     */
    fileprivate func moveAccount(fromPosition sourceIndexPath: IndexPath, toPosition destinationIndexPath: IndexPath) {
        
        if sourceIndexPath == destinationIndexPath {
            return
        }
        
        let moveableAccount = accounts[(sourceIndexPath as NSIndexPath).row]
        accounts.remove(at: (sourceIndexPath as NSIndexPath).row)
        accounts.insert(moveableAccount, at: (destinationIndexPath as NSIndexPath).row)
        
        AccountManager.sharedInstance.updatePosition(forAccounts: accounts)
    }
    
    /**
        Asks the user to change the title for an existing account and makes
        the change accordingly.
     
        - Parameter indexPath: The index path of the account that should get updated.
     */
    fileprivate func changeTitle(forAccountAtIndexPath indexPath: IndexPath) {
        
        let account = accounts[indexPath.row]
        
        let accountTitleChangerAlert = UIAlertController(title: "CHANGE".localized(), message: "INPUT_NEW_ACCOUNT_NAME".localized(), preferredStyle: .alert)
        
        accountTitleChangerAlert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: nil))
        
        accountTitleChangerAlert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { [unowned self] (action) in
            
            let titleTextField = accountTitleChangerAlert.textFields![0] as UITextField
            if let newTitle = titleTextField.text {
                
                self.accounts[indexPath.row].title = newTitle
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                
                AccountManager.sharedInstance.updateTitle(forAccount: self.accounts[indexPath.row], withNewTitle: newTitle)
            }
        }))
        
        accountTitleChangerAlert.addTextField { (textField) in
            textField.text = account.title
        }
        
        present(accountTitleChangerAlert, animated: true, completion: nil)
    }
    
    // MARK: - View Controller Outlet Actions
    
    /**
        Unwinds to the account list view controller and reloads all
        accounts to show.
     */
    @IBAction func unwindToAccountListViewController(_ segue: UIStoryboardSegue) {
        
        accounts = AccountManager.sharedInstance.accounts()
        tableView.reloadData()
        createEditButtonItemIfNeeded()
    }
}

// MARK: - Table View Data Source

extension AccountListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell") as! AccountTableViewCell
        cell.title = accounts[indexPath.row].title
        
        return cell
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            
            deleteAccount(atIndexPath: indexPath)
            
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        moveAccount(fromPosition: sourceIndexPath, toPosition: destinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - Table View Delegate

extension AccountListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.isEditing {
            changeTitle(forAccountAtIndexPath: indexPath)
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            performSegue(withIdentifier: "showAccountDetailTabBarController", sender: nil)
        }
    }
}
