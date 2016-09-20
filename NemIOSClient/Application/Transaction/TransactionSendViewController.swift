//
//  TransactionSendViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


/**
    The view controller that lets the user send transactions from
    the current account or the accounts the current account is a 
    cosignatory of.
 */
class TransactionSendViewController: UIViewController, UIScrollViewDelegate, APIManagerDelegate {
    
    // MARK: - View Controller Properties
    
    fileprivate var _apiManager = APIManager()
    fileprivate var _mainWallet :AccountGetMetaData? = nil
    fileprivate var _popup :UIViewController? = nil
    
    var transactionFee :Double = 10;
    var walletData :AccountGetMetaData!
    var xems :Double = 0
    var invoice :InvoiceData? = nil
    var contact :_Correspondent? = State.currentContact
    
    fileprivate var _isEnc = false
    fileprivate let greenColor :UIColor = UIColor(red: 65/256, green: 206/256, blue: 123/256, alpha: 1)
    fileprivate let grayColor :UIColor = UIColor(red: 239 / 255, green: 239 / 255, blue: 244 / 255, alpha: 1)
    fileprivate var _preparedTransaction :_TransferTransaction? = nil
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var toAddressTextField: NEMTextField!
    @IBOutlet weak var amountTextField: NEMTextField!
    @IBOutlet weak var messageTextField: NEMTextField!
    @IBOutlet weak var feeTextField: NEMTextField!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var chooseButon: AccountChooserButton!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var encButton: UIButton!
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!

    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _apiManager.delegate = self
        
        self.navigationBar.delegate = self
        
        updateViewControllerAppearance()
        
//        setSuggestions()
        
//        let observer: NSNotificationCenter = NSNotificationCenter.defaultCenter()
//        
//        observer.addObserver(self, selector: #selector(TransactionSendViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
//        observer.addObserver(self, selector: #selector(TransactionSendViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
//        
//        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
//        let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey!)
//        
//        _apiManager.accountGet(State.currentServer!, account_address: account_address)
//        
//        if contact != nil {
//            toAddressTextField.text = "\(contact!.address)"
//        }
//        
//        if State.invoice != nil {
//            invoice = State.invoice
//            State.invoice = nil
//            toAddressTextField.text = invoice!.address
//            amountTextField.text = invoice!.amount.format().stringByReplacingOccurrencesOfString(" ", withString: "")
//            messageTextField.text = invoice!.message
//            
//            countTransactionFee()
//            self.feeTextField.text = transactionFee.format().stringByReplacingOccurrencesOfString(" ", withString: "")
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.view.endEditing(true)
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller.
    fileprivate func updateViewControllerAppearance() {
        
        customNavigationItem.title = "NEW_TRANSACTION".localized()
        fromLabel.text = "FROM".localized() + ":"
        toLabel.text = "TO".localized() + ":"
        amountLabel.text = "AMOUNT".localized() + ":"
        messageLabel.text = "MESSAGE".localized() + ":"
        feeLabel.text = "FEE".localized() + ":"
        sendButton.setTitle("SEND".localized(), for: UIControlState())
        toAddressTextField.placeholder = "ENTER_ADDRESS".localized()
        amountTextField.placeholder = "ENTER_AMOUNT".localized()
        messageTextField.placeholder = "EMPTY_MESSAGE".localized()
        feeTextField.placeholder = "ENTER_FEE".localized()
    }
    
    final func setSuggestions() {
        let suggestions :[NEMTextField.Suggestion] = []
        
        //        let dataManager = CoreDataManager()
        //        for wallet in dataManager.getWallets() {
        //            let privateKey = HashManager.AES256Decrypt(wallet.privateKey, key: State.loadData!.password!)
        //            let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey!)
        //
        //            var find = false
        //
        //            for suggestion in suggestions {
        //                if suggestion.key == account_address {
        //                    find = true
        //                    break
        //                }
        //            }
        //            if !find {
        //                var sugest = NEMTextField.Suggestion()
        //                sugest.key = account_address
        //                sugest.value = account_address
        //                suggestions.append(sugest)
        //            }
        //
        //            find = false
        //
        //            for suggestion in suggestions {
        //                if suggestion.key == wallet.login {
        //                    find = true
        //                    break
        //                }
        //            }
        //            if !find {
        //                var sugest = NEMTextField.Suggestion()
        //                sugest.key = wallet.login
        //                sugest.value = account_address
        //                suggestions.append(sugest)
        //            }
        //        }
        
        // TODO: Disable whole address book don't handle public keys
        
        //        if AddressBookManager.isAllowed ?? false {
        //            for contact in AddressBookManager.contacts {
        //                var name = ""
        //                if contact.givenName != "" {
        //                    name = contact.givenName
        //                }
        //
        //                if contact.familyName != "" {
        //                    name += " " + contact.familyName
        //                }
        //
        //                for email in contact.emailAddresses{
        //                    if email.label == "NEM" {
        //                        let account_address = email.value as? String ?? " "
        //
        //                        var find = false
        //
        //                        for suggestion in suggestions {
        //                            if suggestion.key == account_address {
        //                                find = true
        //                                break
        //                            }
        //                        }
        //                        if !find {
        //                            var sugest = NEMTextField.Suggestion()
        //                            sugest.key = account_address
        //                            sugest.value = account_address
        //                            suggestions.append(sugest)
        //                        }
        //
        //                        find = false
        //
        //                        for suggestion in suggestions {
        //                            if suggestion.key == name {
        //                                find = true
        //                                break
        //                            }
        //                        }
        //                        if !find {
        //                            var sugest = NEMTextField.Suggestion()
        //                            sugest.key = name
        //                            sugest.value = account_address
        //                            suggestions.append(sugest)
        //                        }
        //                    }
        //                }
        //            }
        //        }
        
        toAddressTextField.suggestions = suggestions
    }
    
    fileprivate final func _showPopUp(_ message :String){
        
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let ok :UIAlertAction = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default) {
            alertAction -> Void in
        }
        
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate final func _sendTransferTransaction() {
        
        let messageBytes :[UInt8] = messageTextField.text!.hexadecimalStringUsingEncoding(String.Encoding.utf8)!.asByteArray()
        
        let transaction :_TransferTransaction = _TransferTransaction()
        
        transaction.timeStamp = Double(Int(TimeSynchronizator.nemTime))
        transaction.amount = Double(xems)
//        transaction.message.payload = messageBytes
//        transaction.message.type = (_isEnc) ? _MessageType.ecrypted.rawValue : _MessageType.normal.rawValue
        transaction.fee = transactionFee
        transaction.recipient = toAddressTextField.text!
        transaction.deadline = Double(Int(TimeSynchronizator.nemTime + waitTime))
        transaction.version = 1
        transaction.signer = walletData.publicKey
        
        if _isEnc
        {
            _preparedTransaction = transaction
            
            _apiManager.accountGet(State.currentServer!, account_address: transaction.recipient)
        } else {
            if messageBytes.count > 160 {
                _showPopUp("VALIDAATION_MESSAGE_LEANGTH".localized())
                return
            }
            _apiManager.prepareAnnounce(State.currentServer!, transaction: transaction)
        }
    }
    
    final func countTransactionFee(_ needUpdate: Bool = true) {
        var text = amountTextField.text!.replacingOccurrences(of: " ", with: "")
        
        text = text.replacingOccurrences(of: ",", with: "")
        
        var amount = Double(text) ?? 0
        
        if amount < 0.000001 && amount != 0 {
            amountTextField.text = "0"
            amount = 0
        }
        
        self.xems = amount
        
        var newFee :Int = 0
        
        if xems >= 8 {
            newFee = Int(max(2, 99 * atan(xems / 150000)))
        }
        else {
            newFee = 10 - Int(xems)
        }
        
        var messageLength = messageTextField.text!.hexadecimalStringUsingEncoding(String.Encoding.utf8)?.asByteArray().count
        
        if _isEnc && messageLength != 0{
            messageLength! += 64
        }
        
        if messageLength != 0 {
            newFee += Int(2 * max(1, Int( messageLength! / 16)))
        }
        
        let atributedText :NSMutableAttributedString = NSMutableAttributedString(string: "FEE".localized() +  ": (" + "MIN".localized() + " ", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!])
        
        atributedText.append(NSMutableAttributedString(string: "\(Int(newFee))", attributes: [
            NSForegroundColorAttributeName : UIColor(red: 51 / 256, green: 191 / 256, blue: 86 / 256, alpha: 1),
            NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 16)!
            ]))
        
        atributedText.append(NSMutableAttributedString(string: " XEM)", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!]))
        feeLabel.attributedText = atributedText
        
        if !needUpdate {
            let currentFee  = Int(feeTextField.text!) ?? 0
            
            newFee = Int(max(newFee, currentFee))
        }
        
        transactionFee = Double(newFee)
    }
    
    func didChouseAccount(_ account: AccountGetMetaData) {
        walletData = account
        
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
        let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey!)
        
        self.encButton?.isEnabled = walletData.address == account_address
        
        if walletData.address != account_address {
            _isEnc = false
            _preparedTransaction = nil
            encButton.backgroundColor = (_isEnc) ? greenColor : grayColor
            countTransactionFee()
            self.feeTextField.text = "\(transactionFee.format())"
        }
        
        encButton.isEnabled = walletData.address == account_address
        
        chooseButon.setTitle(walletData.address.nemName(), for: UIControlState())
        
        let atributedText :NSMutableAttributedString = NSMutableAttributedString(string: "AMOUNT".localized() + " (" + "BALANCE".localized() + ": ", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!])
        
        atributedText.append(NSMutableAttributedString(string: "\((walletData.balance / 1000000).format())", attributes: [
            NSForegroundColorAttributeName : UIColor(red: 51 / 256, green: 191 / 256, blue: 86 / 256, alpha: 1),
            NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 16)!
            ]))
        
        atributedText.append(NSMutableAttributedString(string: "XEM):", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!]))
        amountLabel.attributedText = atributedText
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardHeight:CGFloat = keyboardSize.height - 60
        
        self.scroll.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight , 0)
        self.scroll.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        self.scroll.contentInset = UIEdgeInsets.zero
        self.scroll.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    func accountGetResponceWithAccount(_ account: AccountGetMetaData?) {
        
        if _preparedTransaction != nil && _preparedTransaction!.recipient == account?.address {
            guard let contactPublicKey = account?.publicKey else {
                _showPopUp("NO_PUBLIC_KEY_FOR_ENC".localized())
                return
            }
            
            var encryptedMessage :[UInt8] = Array(repeating: 0, count: 32)
//            encryptedMessage = MessageCrypto.encrypt(_preparedTransaction!.message.payload!, senderPrivateKey: HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)!, recipientPublicKey: contactPublicKey)
//            _preparedTransaction!.message.payload = encryptedMessage
            
            if encryptedMessage.count > 160 {
                _showPopUp("VALIDAATION_MESSAGE_LEANGTH".localized())
                return
            }
            _apiManager.prepareAnnounce(State.currentServer!, transaction: _preparedTransaction!)
            _preparedTransaction = nil
        }
        
        walletData = account
        
        if _mainWallet == nil {
//            if walletData.publicKey == nil {
//                walletData.publicKey = KeyGenerator.generatePublicKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)!)
//            }
            
            _mainWallet = walletData
        }
        
        if account != nil {
            if walletData.cosignatoryOf.count > 0 {
                chooseButon.isHidden = false
                accountLabel.isHidden = true
                chooseButon.setTitle(walletData.address.nemName(), for: UIControlState())
            } else {
                chooseButon.isHidden = true
                accountLabel.isHidden = false
                accountLabel.text = walletData.address.nemName()
            }
            
            let atributedText :NSMutableAttributedString = NSMutableAttributedString(string: "AMOUNT".localized() + " (" + "BALANCE".localized() + ": ", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!])
            
            atributedText.append(NSMutableAttributedString(string: "\((walletData.balance / 1000000).format())", attributes: [
                NSForegroundColorAttributeName : UIColor(red: 51 / 256, green: 191 / 256, blue: 86 / 256, alpha: 1),
                NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 16)!
                ]))
            
            atributedText.append(NSMutableAttributedString(string: " XEM):", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!]))
            amountLabel.attributedText = atributedText
        } else {
            amountLabel.text = "AMOUNT".localized() + ":"
        }
    }
    
    func prepareAnnounceResponceWithTransactions(_ data: [TransactionPostMetaData]?) {
        
        var message :String = ""
        if (data ?? []).isEmpty {
            message = "TRANSACTION_ANOUNCE_FAILED".localized()
        } else {
            message = "TRANSACTION_ANOUNCE_SUCCESS".localized()
        }
        
        _showPopUp(message)
    }
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func encTouchUpInside(_ sender: UIButton) {
        _preparedTransaction = nil
        _isEnc = !_isEnc
        sender.backgroundColor = (_isEnc) ? greenColor : grayColor
        countTransactionFee()
        self.feeTextField.text = "\(transactionFee.format())"
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        countTransactionFee()
        if self.feeTextField.text! != transactionFee.format() && self.feeTextField.text! != ""{
            self.feeTextField.text = transactionFee.format()
        }
    }
    
    @IBAction func textFieldReturnKeyToched(_ sender: UITextField) {
        
        switch sender {
        case toAddressTextField :
            amountTextField.becomeFirstResponder()
        case amountTextField :
            messageTextField.becomeFirstResponder()
        case messageTextField :
            feeTextField.becomeFirstResponder()
        default :
            sender.becomeFirstResponder()
        }
        
        countTransactionFee(sender != feeTextField)
        self.feeTextField.text = transactionFee.format()
        
        var text = self.xems.format().replacingOccurrences(of: " ", with: "")
        text = text.replacingOccurrences(of: ",", with: "")
        
        if text == "0" {
            text = ""
        }
        
        self.amountTextField.text = text
    }
    
    @IBAction func textFieldEditingEnd(_ sender: UITextField) {
        countTransactionFee(sender != feeTextField)
        self.feeTextField.text = transactionFee.format()
        
        var text = self.xems.format().replacingOccurrences(of: " ", with: "")
        text = text.replacingOccurrences(of: ",", with: "")
        
        if text == "0" {
            text = ""
        }
        
        self.amountTextField.text = text
    }
    
    @IBAction func send(_ sender: AnyObject) {
        let amount = Double(amountTextField.text!) ?? 0
        if amount < 0.000001 && amount != 0 {
            countTransactionFee()
            return
        } else {
            countTransactionFee(false)
        }
        
        if Double(self.feeTextField.text!) < transactionFee {
            self.feeTextField.text = "\(transactionFee.format())"
            return
        }
        
        if messageTextField.text?.hexadecimalStringUsingEncoding(String.Encoding.utf8)?.asByteArray().count > 128 {
            _showPopUp("VALIDAATION_MESSAGE_LEANGTH".localized())
            return
        }
        
        if walletData != nil {
            var state = true
            toAddressTextField.text = toAddressTextField.text?.replacingOccurrences(of: "-", with: "")
            state = (state && Validate.stringNotEmpty(toAddressTextField.text))
            state = (state && (Validate.stringNotEmpty(messageTextField.text) || Validate.stringNotEmpty(amountTextField.text)))
            state = (state && Validate.stringNotEmpty(feeTextField.text))
            
            if state {
                if Int64(walletData.balance) >= Int64(xems) + Int64(transactionFee) {
                    _sendTransferTransaction()
                    
                    xems = 0;
                    messageTextField.text = ""
                    amountTextField.text = ""
                    feeTextField.text = ""
                } else {
                    _showPopUp("NOT_ENOUGHT_MONEY".localized())
                }
            } else {
                _showPopUp("FIELDS_EMPTY_ERROR".localized())
            }
            
        } else {
            _showPopUp("SERVER_UNAVAILABLE".localized())
            
            let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
            let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey!)
            
            _apiManager.accountGet(State.currentServer!, account_address: account_address)
        }
    }
    
    @IBAction func endTyping(_ sender: NEMTextField) {
        
        if Int(amountTextField.text!) != nil {
            self.xems = Double(amountTextField.text!)!
        }
        else {
            self.xems = 0
        }
        
        countTransactionFee()
        self.feeTextField.text = "\(transactionFee.format())"
        sender.becomeFirstResponder()
    }
    
//    @IBAction func chouseAccount(sender: AnyObject) {
//        if _popup == nil {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            
//            let accounts :AccountChooserViewController =  storyboard.instantiateViewControllerWithIdentifier("AccountChooserViewController") as! AccountChooserViewController
//            _popup = accounts
//            accounts.view.frame = CGRect(origin: CGPoint(x: scroll.frame.origin.x, y: scroll.frame.origin.y + 5 ), size: scroll.frame.size)
//            
//            accounts.view.layer.opacity = 0
////            accounts.delegate = self
//            
//            var wallets = _mainWallet?.cosignatoryOf ?? []
//            
//            if _mainWallet != nil
//            {
//                wallets.append(self._mainWallet!)
//            }
//            accounts.wallets = wallets
//            
//            if accounts.wallets.count > 0
//            {
//                self.contentView.addSubview(accounts.view)
//                
//                UIView.animateWithDuration(0.5, animations: { () -> Void in
//                    accounts.view.layer.opacity = 1
//                    }, completion: nil)
//            }
//        } else {
//            _popup!.view.removeFromSuperview()
//            _popup!.removeFromParentViewController()
//            _popup = nil
//        }
//    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Navigation Bar Delegate

extension TransactionSendViewController: UINavigationBarDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
