//
//  VerifyTransferTransactionViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit
import SwiftyJSON

///
final class VerifyTransferTransactionViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    public var accountData: AccountData?
    public var activeAccountData: AccountData?
    public var transaction: Transaction?
    
    // MARK: - View Controller Outlets

    @IBOutlet weak var accountTitleLabel: UILabel!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    @IBOutlet weak var accountBalanceChangeLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var transactionSignerLabel: UILabel!
    @IBOutlet weak var transactionRecipientLabel: UILabel!
    @IBOutlet weak var transactionAmountLabel: UILabel!
    @IBOutlet weak var transactionFeeLabel: UILabel!
    @IBOutlet weak var transactionMessageLabel: UILabel!
    @IBOutlet weak var sendTransactionButton: UIButton!
    @IBOutlet weak var editTransactionButton: UIButton!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateAppearance()
        reloadTransactionDetails()
    }
    
    // MARK: - View Controller Outlet Actions

    @IBAction func sendTransaction(_ sender: UIButton) {
        
        sendTransactionButton.isEnabled = false
        announceTransaction(transaction!)
    }
    
    // MARK: - View Controller Helper Methods
    
    ///
    private func reloadTransactionDetails() {
        
        var transferTransaction: TransferTransaction!
        
        if transaction?.type == .multisigTransaction {
            transferTransaction = (transaction as! MultisigTransaction).innerTransaction as! TransferTransaction
        } else {
            transferTransaction = transaction as! TransferTransaction
        }
        
        if activeAccountData?.address == account?.address {
            accountTitleLabel.text = account?.title ?? ""
            accountTitleLabel.lineBreakMode = .byTruncatingTail
        } else {
            accountTitleLabel.text = activeAccountData?.address.nemAddressNormalised() ?? ""
            accountTitleLabel.lineBreakMode = .byTruncatingMiddle
        }
        
        accountBalanceLabel.text = "\(activeAccountData?.balance.format() ?? "0") XEM"
        accountBalanceChangeLabel.text = "-\(transferTransaction.amount + transferTransaction.fee) XEM"
        informationLabel.text = "Verify that all transaction details are correct and proceed by sending the transaction"
        transactionSignerLabel.text = AccountManager.sharedInstance.generateAddress(forPublicKey: transferTransaction.signer).nemAddressNormalised()
        transactionRecipientLabel.text = transferTransaction.recipient.nemAddressNormalised()
        transactionAmountLabel.text = "-\(transferTransaction.amount.format()) XEM"
        transactionFeeLabel.text = "\(transferTransaction.fee.format()) XEM"
        transactionMessageLabel.text = transferTransaction.message?.message != "" ? transferTransaction.message?.message : "-"
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
                        self?.showAlert(withMessage: "TRANSACTION_ANOUNCE_SUCCESS".localized(), completion: {
                            self?.performSegue(withIdentifier: "unwindToAccountDashboardViewController", sender: nil)
                        })
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
            
            self?.sendTransactionButton.isEnabled = true
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
         Shows an alert view controller with the provided alert message.
     
         - Parameter message: The message that should get shown.
         - Parameter completion: An optional action that should get performed on completion.
     */
    fileprivate func showAlert(withMessage message: String, completion: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: "INFO".localized(), message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
            completion?()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    /// Updates the appearance of the view controller.
    private func updateAppearance() {
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        sendTransactionButton.layer.cornerRadius = 10.0
        editTransactionButton.layer.cornerRadius = 10.0
    }
}
