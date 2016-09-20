//
//  InvoiceCreationViewController.swift
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

/// The view controller that lets the user create a new invoice.
class InvoiceCreationViewController: UIViewController {
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var invoiceAccountTitleTextField: UITextField!
    @IBOutlet weak var invoiceAmountTextField: UITextField!
    @IBOutlet weak var invoiceMessageTextField: UITextField!
    @IBOutlet weak var createInvoiceButton: UIButton!

    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateViewControllerAppearance()
        
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        
        let loadData = State.loadData
        
        invoiceAccountTitleTextField.text = State.currentWallet?.login ?? ""
        var text = ""
        
        if Validate.stringNotEmpty(loadData?.invoicePrefix) {
            text = loadData!.invoicePrefix! + "/"
        }
        
//        text = text + "\(_dataManager.getInvoice().count)"
        
        if Validate.stringNotEmpty(loadData?.invoicePostfix) {
            text = text + "/" + loadData!.invoicePostfix!
        }
        
        text = text + ": "
        
        if Validate.stringNotEmpty(loadData?.invoiceMessage) {
            text = text + loadData!.invoiceMessage!
        }
        
        invoiceMessageTextField.text = text
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller on view did load.
    fileprivate func updateViewControllerAppearance() {
        
        invoiceAccountTitleTextField.placeholder = "ENTER_NAME".localized()
        invoiceAmountTextField.placeholder = "ENTER_AMOUNT".localized()
        invoiceMessageTextField.placeholder = "ENTER_MESSAGE".localized()
        createInvoiceButton.setTitle("CREATE".localized(), for: UIControlState())
    }
    
    // MARK: - View Controller Outlet Actions

    @IBAction func hideKeyboard(_ sender: AnyObject) {
        if invoiceAccountTitleTextField.text == "" {
            invoiceAccountTitleTextField.becomeFirstResponder()
        }
        else if invoiceAmountTextField.text == "" {
            invoiceAmountTextField.becomeFirstResponder()
        }
        else if invoiceMessageTextField.text == "" {
            invoiceMessageTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func createInvoiceButtonPressed(_ sender: UIButton) {
        
        let amountValue = Double(invoiceAmountTextField.text!.replacingOccurrences(of: " ", with: "")) ?? 0

        if amountValue < 0.000001 && amountValue != 0 {
            invoiceAmountTextField.text = "0"
            return
        }
        
        if invoiceAccountTitleTextField.text == "" {
            return
        }
        
        if invoiceMessageTextField.text?.hexadecimalStringUsingEncoding(String.Encoding.utf8)?.asByteArray().count > 255 {
            let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: "MESSAGE_LENGTH".localized(), preferredStyle: UIAlertControllerStyle.alert)
            
            let ok :UIAlertAction = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default) {
                alertAction -> Void in
                
//                if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
//                    (self.delegate as! MainVCDelegate).pageSelected(SegueToUnconfirmedTransactionVC)
//                }
            }
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        var invoice :InvoiceData = InvoiceData()
        invoice.name = invoiceAccountTitleTextField.text
        invoice.message = invoiceMessageTextField.text
        invoice.address = AddressGenerator.generateAddressFromPrivateKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)!)
        invoice.amount = amountValue * 1000000
//        invoice.number = Int(CoreDataManager().addInvoice(invoice).number)
//        CoreDataManager().commit()
        State.invoice = invoice
        
//        if self.delegate != nil && self.delegate!.respondsToSelector(Selector("changePage:")) {
//            (self.delegate as! InvoiceViewController).changePage(SegueToCreateInvoiceResult)
//        }
        
        performSegue(withIdentifier: "showInvoiceCreatedViewController", sender: nil)
    }
}
