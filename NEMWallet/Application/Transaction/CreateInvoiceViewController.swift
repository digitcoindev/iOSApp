//
//  CreateInvoiceViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

///
final class CreateInvoiceViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    private var invoiceMessagePlaceholderLabel: UILabel!
    private var invoice: NewInvoice?
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var invoiceRecipientTextField: UITextField!
    @IBOutlet weak var invoiceAmountTextField: UITextField!
    @IBOutlet weak var invoiceMessageTextView: UITextView!
    @IBOutlet weak var invoiceMessageCharsLabel: UILabel!
    @IBOutlet weak var createInvoiceButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        invoiceRecipientTextField.text = account?.title ?? ""
        informationLabel.text = "You can create an invoice in the form of a QR code which you can then share with someone to scan"
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        notificationCenter.addObserver(self, selector: #selector(hideKeyboard), name: Constants.hideKeyboardNotification, object: nil)

        updateAppearance()
        
        invoiceMessagePlaceholderLabel = UILabel()
        invoiceMessagePlaceholderLabel.text = "Enter the message the invoice should contain"
        invoiceMessagePlaceholderLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightSemibold)
        invoiceMessagePlaceholderLabel.sizeToFit()
        invoiceMessageTextView.addSubview(invoiceMessagePlaceholderLabel)
        invoiceMessagePlaceholderLabel.frame.origin = CGPoint(x: 5, y: 8)
        invoiceMessagePlaceholderLabel.textColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1.0)
        invoiceMessagePlaceholderLabel.isHidden = !invoiceMessageTextView.text.isEmpty
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "showInvoiceViewController":
            
            let destinationViewController = segue.destination as! InvoiceViewController
            destinationViewController.account = account
            destinationViewController.invoice = invoice
            
        default:
            return
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        invoiceMessagePlaceholderLabel.isHidden = !invoiceMessageTextView.text.isEmpty
        updateInvoiceMessageCharsLabel()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        invoiceMessageTextView.resignFirstResponder()
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
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func createInvoice(_ sender: UIButton) {
        
        guard invoiceRecipientTextField.text != nil else { return }
        guard invoiceAmountTextField.text != nil else { return }
        guard invoiceMessageTextView.text != nil else { return }
        
        let invoiceRecipient = invoiceRecipientTextField.text!
        let invoiceAmount = Double(invoiceAmountTextField.text!.replacingOccurrences(of: " ", with: "")) ?? 0.0
        let invoiceMessage = invoiceMessageTextView.text!
        
        if invoiceAmount < 0.000001 && invoiceAmount != 0 {
            invoiceAmountTextField.text = "0"
            return
        }
        if invoiceRecipient == "" {
            return
        }
        if invoiceMessage.hexadecimalStringUsingEncoding(String.Encoding.utf8)!.asByteArray().count > 1024 {
            
            let messageLengthAlert = UIAlertController(title: "INFO".localized(), message: "MESSAGE_LENGTH".localized(), preferredStyle: UIAlertControllerStyle.alert)
            
            messageLengthAlert.addAction(UIAlertAction(title: "OK".localized(), style: .cancel, handler: nil))
            
            present(messageLengthAlert, animated: true, completion: nil)
            
            return
        }
        
        let invoice = NewInvoice(recipient: invoiceRecipient, amount: invoiceAmount, message: invoiceMessage)
        self.invoice = invoice
        
        performSegue(withIdentifier: "showInvoiceViewController", sender: nil)
    }
    
    @IBAction func unwindToCreateInvoiceViewController(_ sender: UIStoryboardSegue) {
        return
    }
    
    // MARK: - View Controller Helper Methods
    
    ///
    private func updateInvoiceMessageCharsLabel() {
        
        let invoiceMessageText = invoiceMessageTextView.text!.hexadecimalStringUsingEncoding(String.Encoding.utf8) ?? String()
        let invoiceMessageByteArray: [UInt8] = invoiceMessageText.asByteArray()
        let invoiceMessageBytesLeft = 1024 - invoiceMessageByteArray.count
        
        invoiceMessageCharsLabel.text = "\(invoiceMessageBytesLeft) characters left"
        
        if invoiceMessageBytesLeft <= 0 {
            invoiceMessageCharsLabel.textColor = Constants.outgoingColor
        } else {
            invoiceMessageCharsLabel.textColor = Constants.grayColor
        }
    }
    
    ///
    public func hideKeyboard() {
        
        invoiceRecipientTextField.resignFirstResponder()
        invoiceAmountTextField.resignFirstResponder()
        invoiceMessageTextView.resignFirstResponder()
    }
    
    /// Updates the appearance of the view controller.
    private func updateAppearance() {
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        createInvoiceButton.layer.cornerRadius = 10.0
    }
}
