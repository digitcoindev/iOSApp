//
//  InvoiceCreateViewController.swift
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


class InvoiceCreateViewController: UIViewController
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var message: NEMTextField!
    @IBOutlet weak var name: NEMTextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var createButton: UIButton!

//    private let _dataManager = CoreDataManager()

    override func viewDidLoad() {
        super.viewDidLoad()
//        State.fromVC = SegueToCreateInvoice

        amount.placeholder = "ENTER_AMOUNT".localized()
        name.placeholder = "ENTER_NAME".localized()
        message.placeholder = "ENTER_MESSAGE".localized()
        
        createButton.setTitle("CREATE".localized(), for: UIControlState())
        
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        
        let loadData = State.loadData
        
        name.text = State.currentWallet?.login ?? ""
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
        
        message.text = text
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        State.currentVC = SegueToCreateInvoice
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func hideKeyboard(_ sender: AnyObject) {
        if name.text == "" {
            name.becomeFirstResponder()
        }
        else if amount.text == "" {
            amount.becomeFirstResponder()
        }
        else if message.text == "" {
            message.becomeFirstResponder()
        }
    }
    
    @IBAction func confirm(_ sender: AnyObject) {
        
        let amountValue = Double(amount.text!.replacingOccurrences(of: " ", with: "")) ?? 0

        if amountValue < 0.000001 && amount != 0 {
            amount.text = "0"
            return
        }
        
        if name.text == "" {
            return
        }
        
        if message.text?.hexadecimalStringUsingEncoding(String.Encoding.utf8)?.asByteArray().count > 255 {
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
        invoice.name = name.text
        invoice.message = message.text
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
