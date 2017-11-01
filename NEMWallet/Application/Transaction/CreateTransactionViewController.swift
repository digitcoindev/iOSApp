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
    fileprivate var accountData: AccountData?
    fileprivate var activeAccountData: AccountData?
    private var transactionFee = Double()
    private var transactionMessagePlaceholderLabel: UILabel!
    fileprivate var multisigAccounts = [AccountData]()
    private var transaction: Transaction?
    private var recipientPublicKey: String?
    
    /// The latest market info, used to display fiat account balances.
    public var marketInfo: (xemPrice: Double, btcPrice: Double) = (0, 0)
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var accountTitleLabel: UILabel!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    @IBOutlet weak var accountFiatBalanceLabel: UILabel!
    @IBOutlet weak var multisigAccountsTableView: UITableView!
    @IBOutlet weak var transactionRecipientTextField: UITextField!
    @IBOutlet weak var transactionAmountTextField: UITextField!
    @IBOutlet weak var transactionFeeLabel: UILabel!
    @IBOutlet weak var transactionMessageTextView: UITextView!
    @IBOutlet weak var transactionMessageCharsLabel: UILabel!
    @IBOutlet weak var transactionMessageEncryptedSwitch: UISwitch!
    @IBOutlet weak var transactionMessageEncryptedImageView: UIImageView!
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
        transactionMessagePlaceholderLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.semibold)
        transactionMessagePlaceholderLabel.sizeToFit()
        transactionMessageTextView.addSubview(transactionMessagePlaceholderLabel)
        transactionMessagePlaceholderLabel.frame.origin = CGPoint(x: 5, y: 8)
        transactionMessagePlaceholderLabel.textColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1.0)
        transactionMessagePlaceholderLabel.isHidden = !transactionMessageTextView.text.isEmpty
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "showVerifyTransactionViewController":
            
            let destinationViewController = segue.destination as! VerifyTransferTransactionViewController
            destinationViewController.account = account
            destinationViewController.accountData = accountData
            destinationViewController.activeAccountData = activeAccountData
            destinationViewController.transaction = transaction
            
        default:
            return
        }
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
    fileprivate func updateAccountSummary() {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.numberStyle = .currency
        
        let accountBalance = activeAccountData?.balance ?? 0
        
        if activeAccountData?.address == account?.address {
            accountTitleLabel.text = account?.title ?? ""
            accountTitleLabel.lineBreakMode = .byTruncatingTail
        } else {
            accountTitleLabel.text = activeAccountData?.address.nemAddressNormalised() ?? ""
            accountTitleLabel.lineBreakMode = .byTruncatingMiddle
        }

        accountBalanceLabel.text = "\(accountBalance.format()) XEM"
        accountFiatBalanceLabel.text = numberFormatter.string(from: (marketInfo.xemPrice * marketInfo.btcPrice * accountBalance) as NSNumber)
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
                        self?.multisigAccounts.append(accountData)
                        self?.multisigAccounts += accountData.cosignatoryOf ?? []
                        self?.multisigAccountsTableView.reloadData()
                        self?.updateAccountSummary()
                        
                        if self?.transactionMessageEncryptedSwitch.isOn == false {
                            self?.verifyTransactionButton.isEnabled = true
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
    
    /**
         Fetches the account data (balance, cosignatories, etc.) for the account from the active NIS.
     
         - Parameter accountAddress: The address of the account for which the account data should get fetched.
     */
    fileprivate func fetchAccountData(forAccountWithAddress accountAddress: String) {
        
        NEMProvider.request(NEM.accountData(accountAddress: accountAddress)) { [weak self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    let accountData = try json.mapObject(AccountData.self)
                    
                    DispatchQueue.main.async {
                        
                        self?.recipientPublicKey = accountData.publicKey
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
    @objc public func hideKeyboard() {
        
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
        var transactionMessageByteArray: [UInt8] = transactionMessageText.asByteArray()
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
        guard recipientPublicKey != nil else {
            showAlert(withMessage: "Message Encryption failed. Try sending again.")
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
        
        if encryptMessage {
            var transactionEncryptedMessageByteArray: [UInt8] = Array(repeating: 0, count: 32)
            transactionEncryptedMessageByteArray = TransactionManager.sharedInstance.encryptMessage(transactionMessageByteArray, senderEncryptedPrivateKey: account!.privateKey, recipientPublicKey: recipientPublicKey!)
            transactionMessageByteArray = transactionEncryptedMessageByteArray
        }
        
        let transferTransaction = TransferTransaction(version: transactionVersion, timeStamp: transactionTimeStamp, amount: transactionAmount, fee: transactionFee, recipient: transactionRecipient, message: nil, deadline: transactionDeadline, signer: transactionSigner!)
        
        let transactionMessage = Message(type: encryptMessage ? MessageType.encrypted : MessageType.unencrypted, payload: transactionMessageByteArray, message: transactionMessageTextView.text!)
        transferTransaction?.message = transactionMessage
        
        // Check if the transaction is a multisig transaction
        if activeAccountData!.publicKey != account!.publicKey {
            
            let multisigTransaction = MultisigTransaction(version: transferTransaction!.version, timeStamp: transferTransaction!.timeStamp, fee: 0.15, deadline: transferTransaction!.deadline, signer: account!.publicKey, innerTransaction: transferTransaction!)
            transaction = multisigTransaction
            
        } else {
            
            transaction = transferTransaction
        }
        
        verifyTransactionButton.isEnabled = true
        performSegue(withIdentifier: "showVerifyTransactionViewController", sender: nil)
    }
    
    @IBAction func showMultisigAccountsMenu(_ sender: UITapGestureRecognizer) {
        
        guard activeAccountData != nil else { return }
        
        if multisigAccountsTableView.isHidden == true {
            hideKeyboard()
            multisigAccountsTableView.isHidden = false
            verifyTransactionButton.isEnabled = false
        } else {
            multisigAccountsTableView.isHidden = true
            verifyTransactionButton.isEnabled = true
        }
    }
    
    @IBAction func messageEncryptionToggled(_ sender: UISwitch) {
        calculateTransactionFee()
        
        if transactionMessageEncryptedSwitch.isOn && recipientPublicKey == nil {
            verifyTransactionButton.isEnabled = false
        } else if accountData != nil {
            verifyTransactionButton.isEnabled = true
        }
        
        if transactionMessageEncryptedSwitch.isOn {
            transactionMessageEncryptedImageView.isHidden = false
        } else {
            transactionMessageEncryptedImageView.isHidden = true
        }
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
    
    @IBAction func transactionRecipientChanged(_ sender: UITextField) {
        
        let transactionRecipient = transactionRecipientTextField.text!.replacingOccurrences(of: "-", with: "")
        
        fetchAccountData(forAccountWithAddress: transactionRecipient)
    }
    
    @IBAction func unwindToCreateTransactionViewController(_ sender: UIStoryboardSegue) {
        return
    }
}

extension CreateTransactionViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table View Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return multisigAccounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let multisigAccountData = multisigAccounts[indexPath.row]
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.numberStyle = .currency
        
        let multisigAccountTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MultisigAccountTableViewCell") as! MultisigAccountTableViewCell
        
        if multisigAccountData == accountData {
            multisigAccountTableViewCell.accountTitleLabel.text = account!.title
            multisigAccountTableViewCell.accountTitleLabel.lineBreakMode = .byTruncatingTail
        } else {
            multisigAccountTableViewCell.accountTitleLabel.text = multisigAccountData.address.nemAddressNormalised()
            multisigAccountTableViewCell.accountTitleLabel.lineBreakMode = .byTruncatingMiddle
        }
        
        if multisigAccountData == activeAccountData {
            multisigAccountTableViewCell.accessoryType = .checkmark
        } else {
            multisigAccountTableViewCell.accessoryType = .none
        }
        
        multisigAccountTableViewCell.accountBalanceLabel.text = "\(multisigAccountData.balance.format()) XEM"
        multisigAccountTableViewCell.accountFiatBalanceLabel.text = numberFormatter.string(from: (marketInfo.xemPrice * marketInfo.btcPrice * multisigAccountData.balance) as NSNumber)
        
        return multisigAccountTableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        activeAccountData = multisigAccounts[indexPath.row]
        updateAccountSummary()
        
        verifyTransactionButton.isEnabled = true
        transactionMessageEncryptedSwitch.isEnabled = activeAccountData?.address == self.accountData?.address
        transactionMessageEncryptedSwitch.isOn = false
        
        multisigAccountsTableView.reloadData()
        multisigAccountsTableView.isHidden = true
    }
}
