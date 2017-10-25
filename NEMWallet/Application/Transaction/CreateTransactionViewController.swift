//
//  CreateTransactionViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit
import SwiftyJSON

///
final class CreateTransactionViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    public var accountBalance = Double()
    public var accountFiatBalance = Double()
    fileprivate var accountData: AccountData?
    fileprivate var activeAccountData: AccountData?
    private var transactionFee = Double()
    private var transactionMessagePlaceholderLabel: UILabel!
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var accountTitleLabel: UILabel!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    @IBOutlet weak var accountFiatBalanceLabel: UILabel!
    @IBOutlet weak var transactionRecipientTextField: UITextField!
    @IBOutlet weak var transactionAmountTextField: UITextField!
    @IBOutlet weak var transactionFeeLabel: UILabel!
    @IBOutlet weak var transactionMessageTextView: UITextView!
    @IBOutlet weak var transactionMessageCharsLabel: UILabel!
    @IBOutlet weak var transactionMessageEncryptedSwitch: UISwitch!
    @IBOutlet weak var verifyTransactionButton: UIButton!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        notificationCenter.addObserver(self, selector: #selector(hideKeyboard), name: Constants.hideKeyboardNotification, object: nil)
        
        verifyTransactionButton.isEnabled = false
        
        guard account != nil else {
            print("Critical: Account not available!")
            return
        }

        updateAppearance()
        updateAccountSummary()
        fetchAccountData(forAccount: account!)
        calculateTransactionFee()
        
        transactionMessagePlaceholderLabel = UILabel()
        transactionMessagePlaceholderLabel.text = "Enter the message you’d like to send"
        transactionMessagePlaceholderLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightSemibold)
        transactionMessagePlaceholderLabel.sizeToFit()
        transactionMessageTextView.addSubview(transactionMessagePlaceholderLabel)
        transactionMessagePlaceholderLabel.frame.origin = CGPoint(x: 5, y: 8)
        transactionMessagePlaceholderLabel.textColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1.0)
        transactionMessagePlaceholderLabel.isHidden = !transactionMessageTextView.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        transactionMessagePlaceholderLabel.isHidden = !transactionMessageTextView.text.isEmpty
        calculateTransactionFee()
        updateTransactionMessageCharsLabel()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        transactionMessageTextView.resignFirstResponder()
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    // MARK: - View Controller Helper Methods
    
    ///
    private func updateAccountSummary() {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.numberStyle = .currency
        
        accountTitleLabel.text = account?.title ?? ""
        accountBalanceLabel.text = "\(accountBalance.format()) XEM"
        accountFiatBalanceLabel.text = numberFormatter.string(from: accountFiatBalance as NSNumber)
    }
    
    /**
         Signs and announces a new transaction to the NIS.
     
         - Parameter transaction: The transaction object that should get signed and announced.
     */
    fileprivate func announceTransaction(_ transaction: Transaction) {
        
        let requestAnnounce = TransactionManager.sharedInstance.signTransaction(transaction, account: account!)
        
        NEMProvider.request(NEM.announceTransaction(requestAnnounce: requestAnnounce)) { [weak self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    let responseJSON = JSON(data: response.data)
                    try self?.validateAnnounceTransactionResult(responseJSON)
                    
                    DispatchQueue.main.async {
                        
                        self?.showAlert(withMessage: "TRANSACTION_ANOUNCE_SUCCESS".localized())
                    }
                    
                } catch TransactionAnnounceValidation.failure(let errorMessage) {
                    
                    DispatchQueue.main.async {
                        
                        print("Failure: \(response.statusCode)")
                        self?.showAlert(withMessage: errorMessage)
                    }
                    
                } catch {
                    
                    DispatchQueue.main.async {
                        
                        print("Failure: \(response.statusCode)")
                        self?.showAlert(withMessage: "TRANSACTION_ANOUNCE_FAILED".localized())
                    }
                }
                
            case let .failure(error):
                
                DispatchQueue.main.async {
                    
                    print(error)
                    self?.showAlert(withMessage: "TRANSACTION_ANOUNCE_FAILED".localized())
                }
            }
            
            self?.verifyTransactionButton.isEnabled = true
        }
    }
    
    /**
         Validates the response (announce transaction result object) of the NIS
         regarding the announcement of the transaction.
     
         - Parameter responseJSON: The response of the NIS JSON formatted.
     
         - Throws:
         - TransactionAnnounceValidation.Failure if the announcement of the transaction wasn't successful.
     */
    fileprivate func validateAnnounceTransactionResult(_ responseJSON: JSON) throws {
        
        guard let responseCode = responseJSON["code"].int else { throw TransactionAnnounceValidation.failure(errorMessage: "TRANSACTION_ANOUNCE_FAILED".localized()) }
        let responseMessage = responseJSON["message"].stringValue
        
        switch responseCode {
        case 1:
            return
        default:
            throw TransactionAnnounceValidation.failure(errorMessage: responseMessage)
        }
    }
    
    /**
         Fetches the account data (balance, cosignatories, etc.) for the current account from the active NIS.
     
         - Parameter account: The current account for which the account data should get fetched.
     */
    fileprivate func fetchAccountData(forAccount account: Account) {
        
        NEMProvider.request(NEM.accountData(accountAddress: account.address)) { [weak self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    var accountData = try json.mapObject(AccountData.self)
                    
                    if accountData.publicKey == "" {
                        accountData.publicKey = account.publicKey
                    }
                    
                    DispatchQueue.main.async {
                        
                        self?.accountData = accountData
                        self?.activeAccountData = accountData
                        self?.verifyTransactionButton.isEnabled = true
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
    
    /// Calculates the fee for the transaction and updates the transaction fee text field accordingly.
    fileprivate func calculateTransactionFee() {
        
        let transactionAmountString = transactionAmountTextField.text!.replacingOccurrences(of: " ", with: "")
        var transactionAmount = Double(transactionAmountString) ?? 0.0
        
        if transactionAmount < 0.000001 && transactionAmount != 0 {
            transactionAmountTextField.text = "0"
            transactionAmount = 0
        }
        
        var transactionFee = 0.0
        transactionFee = TransactionManager.sharedInstance.calculateFee(forTransactionWithAmount: transactionAmount)
        
        let transactionMessageByteArray = transactionMessageTextView.text!.hexadecimalStringUsingEncoding(String.Encoding.utf8)!.asByteArray()
        let transactionMessageLength = transactionMessageTextView.text!.hexadecimalStringUsingEncoding(String.Encoding.utf8)!.asByteArray().count
        if transactionMessageLength != 0 {
            transactionFee += TransactionManager.sharedInstance.calculateFee(forTransactionWithMessage: transactionMessageByteArray, isEncrypted: transactionMessageEncryptedSwitch.isOn)
        }
        
        self.transactionFee = transactionFee
        transactionFeeLabel.text = "\(transactionFee) XEM"
    }
    
    ///
    private func updateTransactionMessageCharsLabel() {
        
        let transactionMessageText = transactionMessageTextView.text!.hexadecimalStringUsingEncoding(String.Encoding.utf8) ?? String()
        let transactionMessageByteArray: [UInt8] = transactionMessageText.asByteArray()
        let transactionMessageBytesLeft = 1024 - transactionMessageByteArray.count
        
        transactionMessageCharsLabel.text = "\(transactionMessageBytesLeft) characters left"
        
        if transactionMessageBytesLeft <= 0 {
            transactionMessageCharsLabel.textColor = Constants.outgoingColor
        } else {
            transactionMessageCharsLabel.textColor = Constants.grayColor
        }
    }
    
    /**
         Shows an alert view controller with the provided alert message.
     
         - Parameter message: The message that should get shown.
         - Parameter completion: An optional action that should get performed on completion.
     */
    fileprivate func showAlert(withMessage message: String) {
        
        let alert = UIAlertController(title: "INFO".localized(), message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    ///
    public func hideKeyboard() {
        
        transactionRecipientTextField.resignFirstResponder()
        transactionAmountTextField.resignFirstResponder()
        transactionMessageTextView.resignFirstResponder()
    }
    
    /// Updates the appearance of the view controller.
    private func updateAppearance() {
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        verifyTransactionButton.layer.cornerRadius = 10.0
    }
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func verifyTransaction(_ sender: UIButton) {
        
        sender.isEnabled = false
        hideKeyboard()
        
        guard transactionRecipientTextField.text != nil else { sender.isEnabled = true; return }
        guard transactionAmountTextField.text != nil else { sender.isEnabled = true; return }
        guard transactionMessageTextView.text != nil else { sender.isEnabled = true; return }
        
        let encryptMessage = transactionMessageEncryptedSwitch.isOn
        let transactionVersion = 1
        let transactionTimeStamp = Date(timeIntervalSince1970: TimeManager.sharedInstance.currentNetworkTime)
        let transactionAmount = Double(transactionAmountTextField.text!) ?? 0.0
        let transactionRecipient = transactionRecipientTextField.text!.replacingOccurrences(of: "-", with: "")
        let transactionMessageText = transactionMessageTextView.text!.hexadecimalStringUsingEncoding(String.Encoding.utf8) ?? String()
        let transactionMessageByteArray: [UInt8] = transactionMessageText.asByteArray()
        let transactionDeadline = Int(TimeManager.sharedInstance.currentNetworkTime + Constants.transactionDeadline)
        let transactionSigner = activeAccountData!.publicKey
        
        calculateTransactionFee()
        
        if transactionAmount < 0.000001 && transactionAmount != 0 {
            transactionAmountTextField!.text = "0"
            sender.isEnabled = true
            return
        }
        guard TransactionManager.sharedInstance.validateAccountAddress(transactionRecipient) else {
            showAlert(withMessage: "ACCOUNT_ADDRESS_INVALID".localized())
            sender.isEnabled = true
            return
        }
        guard activeAccountData!.balance > transactionAmount else {
            showAlert(withMessage: "ACCOUNT_NOT_ENOUGHT_MONEY".localized())
            sender.isEnabled = true
            return
        }
        guard TransactionManager.sharedInstance.validateHexadecimalString(transactionMessageText) == true else {
            showAlert(withMessage: "NOT_A_HEX_STRING".localized())
            sender.isEnabled = true
            return
        }
        if encryptMessage {
            if transactionMessageByteArray.count > 976 {
                showAlert(withMessage: "VALIDAATION_MESSAGE_LEANGTH".localized())
                sender.isEnabled = true
                return
            }
        } else {
            if transactionMessageByteArray.count > 1024 {
                showAlert(withMessage: "VALIDAATION_MESSAGE_LEANGTH".localized())
                sender.isEnabled = true
                return
            }
        }
        
//        if willEncrypt {
//            var transactionEncryptedMessageByteArray: [UInt8] = Array(repeating: 0, count: 32)
//            transactionEncryptedMessageByteArray = TransactionManager.sharedInstance.encryptMessage(transactionMessageByteArray, senderEncryptedPrivateKey: account!.privateKey, recipientPublicKey: recipientPublicKey)
//            transactionMessageByteArray = transactionEncryptedMessageByteArray
//        }
        
        let transferTransaction = TransferTransaction(version: transactionVersion, timeStamp: transactionTimeStamp, amount: transactionAmount * 1000000, fee: transactionFee * 1000000, recipient: transactionRecipient, message: nil, deadline: transactionDeadline, signer: transactionSigner!)
        
        if !encryptMessage {
            let transactionMessage = Message(type: encryptMessage ? MessageType.encrypted : MessageType.unencrypted, payload: transactionMessageByteArray, message: transactionMessageTextView.text!)
            transferTransaction?.message = transactionMessage
            
            // Check if the transaction is a multisig transaction
            if activeAccountData!.publicKey != account!.publicKey {
                
                let multisigTransaction = MultisigTransaction(version: transferTransaction!.version, timeStamp: transferTransaction!.timeStamp, fee: 0.15 * 1000000, deadline: transferTransaction!.deadline, signer: account!.publicKey, innerTransaction: transferTransaction!)
                announceTransaction(multisigTransaction!)
                
            } else {
                
                announceTransaction(transferTransaction!)
            }
        }
    }
    
    @IBAction func messageEncryptionToggled(_ sender: UISwitch) {
        calculateTransactionFee()
    }

    @IBAction func transactionDetailsChanged(_ sender: UITextField) {
        calculateTransactionFee()
    }
    
    @IBAction func editingEnded(_ sender: UITextField) {
        
        switch sender {
        case transactionRecipientTextField:
            transactionAmountTextField.becomeFirstResponder()
        case transactionAmountTextField:
            transactionMessageTextView.becomeFirstResponder()
        default:
            return
        }
    }
}
