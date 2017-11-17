//
//  RecoveryViewController.swift
//  NEMWallet
//
//  Created by Thomas Oehri on 22.09.17.
//  Copyright © 2017 NEM. All rights reserved.
//

import UIKit
import SwiftyJSON

class RecoveryViewController: UITableViewController {
    
    var account: Account?
    var encryptedPrivateKey: String? = String()
    var randomSalt: String? = String()
    var applicationPassword: String? = String()

    @IBOutlet weak var encryptedPrivateKeyTextField: UITextField!
    @IBOutlet weak var randomSaltTextField: UITextField!
    @IBOutlet weak var encryptedApplicationPasswordTextField: UITextField!
    @IBOutlet weak var decryptedPrivateKeyTextField: UITextField!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        account = AccountManager.sharedInstance.activeAccount
        
        guard account != nil else {
            showAlert(withMessage: "No account data available!", title: "Error")
            return
        }
        
        encryptedPrivateKey = account?.privateKey
        randomSalt = SettingsManager.sharedInstance.authenticationSalt()
        
        updateView()
    }
    
    func updateView() {
        
        encryptedPrivateKeyTextField.text = encryptedPrivateKey ?? "No encrypted private key available"
        randomSaltTextField.text = randomSalt ?? "No random salt available"
        encryptedApplicationPasswordTextField.text = applicationPassword ?? "Enter the application password"
    }
    
    func decrypt() {
        
        do {
            let randomSaltByteArray = try randomSalt?.asByteArray()
            let encryptedPrivateKeyByteArray = try encryptedPrivateKey?.asByteArray()
            
            if randomSaltByteArray == nil || encryptedPrivateKeyByteArray == nil || encryptedPrivateKey == nil || applicationPassword == nil || randomSalt == nil || encryptedPrivateKeyByteArray!.count < 16 {
                throw Result.failure
            }
            
            let randomSaltData = NSData(bytes: try randomSalt!.asByteArray(), length: try randomSalt!.asByteArray().count)
            let newPasswordHash: NSData? = try HashManager.generateAesKeyForString(applicationPassword!, salt: randomSaltData, roundCount: 2000) ?? nil
            
            if newPasswordHash == nil {
                throw Result.failure
            }
            
            let encryptedApplicationPassword = newPasswordHash!.hexadecimalString()
            
            let inputBytes = try encryptedPrivateKey!.asByteArray()
            let customizedIV =  Array(inputBytes[0..<16])
            let encryptedBytes = Array(inputBytes[16..<inputBytes.count])
            var data :NSData? = NSData(bytes: encryptedBytes, length: encryptedBytes.count)
            data = data?.aesDecrypt(key: try encryptedApplicationPassword.asByteArray(), iv: customizedIV)
            
            let decryptedPrivateKey = data?.toHexString() ?? "Couldn't decrypt private key - invalid data!"
            
            decryptedPrivateKeyTextField.text = decryptedPrivateKey
            
            let accountAddress = AccountManager.sharedInstance.generateAddress(forPrivateKey: decryptedPrivateKey)
            fetchAccountData(forAccount: accountAddress)
            
        } catch {
            decryptedPrivateKeyTextField.text = "Couldn't decrypt private key - invalid data!"
            return
        }
    }
    
    fileprivate func showAlert(withMessage message: String, title: String, completion: ((Void) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
            completion?()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func fetchAccountData(forAccount account: String) {
        
        nisProvider.request(NIS.accountData(accountAddress: account)) { [weak self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    var accountData = try json.mapObject(AccountData.self)
                    
                    DispatchQueue.main.async {
                        
                        let accountBalance = accountData.balance
                        self?.accountBalanceLabel.text = (accountBalance! / 1000000).format() ?? ""
                        
                        if accountBalance! > 0.0 {
                            self?.showAlert(withMessage: "This account seems to be the one you were looking for! Copy the Decrypted Private Key and save it!", title: "SUCCESS!")
                        }
                    }
                    
                } catch {
                    
                    DispatchQueue.main.async {
                        
                        print("Failure: \(response.statusCode)")
                    }
                }
                
            case let .failure(error):
                
                DispatchQueue.main.async {
                    
                    print(error)
                }
            }
        }
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {
        
        encryptedPrivateKey = encryptedPrivateKeyTextField.text
        randomSalt = randomSaltTextField.text
        applicationPassword = encryptedApplicationPasswordTextField.text
        
        decrypt()
    }
}
