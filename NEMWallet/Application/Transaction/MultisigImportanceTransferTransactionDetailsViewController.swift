//
//  MultisigImportanceTransferTransactionDetailsViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit
import SwiftyJSON

///
final class MultisigImportanceTransferTransactionDetailsViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    public var multisigTransaction: MultisigTransaction?
    private var multisigAccountData: AccountData?
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var transactionTypeLabel: UILabel!
    @IBOutlet weak var transactionTypeLabelTopToSuperviewConstraint: NSLayoutConstraint!
    @IBOutlet weak var transactionTypeLabelTopToInformationViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var transactionDateLabel: UILabel!
    @IBOutlet weak var transactionRemoteAccountLabel: UILabel!
    @IBOutlet weak var transactionModeLabel: UILabel!
    @IBOutlet weak var transactionFeeLabel: UILabel!
    @IBOutlet weak var transactionBlockHeightLabel: UILabel!
    @IBOutlet weak var transactionHashLabel: UILabel!
    @IBOutlet weak var multisigTransactionHashLabel: UILabel!
    @IBOutlet weak var multisigTransactionSignaturesLabel: UILabel!
    @IBOutlet weak var multisigSignaturesTableView: UITableView!
    @IBOutlet weak var multisigSignaturesTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var multisigSignaturesTableViewBottomToSuperviewConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionsView: UIView!
    @IBOutlet weak var actionsViewBottomToSuperviewConstraint: NSLayoutConstraint!
    @IBOutlet weak var signMultisigTransactionButton: UIButton!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAppearance()
        reloadTransactionDetails()
        fetchMultisigAccountData()
    }
    
    override func viewDidLayoutSubviews() {
        multisigSignaturesTableViewHeightConstraint.constant = multisigSignaturesTableView.contentSize.height
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Reloads all transaction details with the newest data.
    internal func reloadTransactionDetails() {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.numberStyle = .currency
        
        guard multisigTransaction != nil else { return }
        
        switch multisigTransaction!.type {
        case .multisigTransaction:
            
            switch multisigTransaction!.innerTransaction.type {
            case .importanceTransferTransaction:
                
                let importanceTransferTransaction = multisigTransaction!.innerTransaction as! ImportanceTransferTransaction
                
                informationView.isHidden = true
                transactionTypeLabelTopToInformationViewConstraint.isActive = false
                transactionTypeLabelTopToSuperviewConstraint.isActive = true
                
                transactionTypeLabel.text = "Multisig Importance Transfer Transaction"
                transactionDateLabel.text = importanceTransferTransaction.timeStamp.format()
                transactionRemoteAccountLabel.text = AccountManager.sharedInstance.generateAddress(forPublicKey: importanceTransferTransaction.remoteAccount).nemAddressNormalised()
                
                if importanceTransferTransaction.mode == 1 {
                    transactionModeLabel.text = "Activation"
                    transactionModeLabel.textColor = Constants.incomingColor
                } else {
                    transactionModeLabel.text = "Deactivation"
                    transactionModeLabel.textColor = Constants.outgoingColor
                }
                
                transactionFeeLabel.text = "\(importanceTransferTransaction.fee.format()) XEM"
                transactionBlockHeightLabel.text = importanceTransferTransaction.metaData?.height != nil ? "\(importanceTransferTransaction.metaData!.height!)" : "Unconfirmed"
                transactionHashLabel.text = "\(importanceTransferTransaction.metaData?.hash ?? "-")"
                multisigTransactionHashLabel.text = "\(multisigTransaction?.metaData?.multisigHash ?? "-")"
                
                if multisigAccountData != nil {
                    guard let multisigSignatures = multisigTransaction!.signatures?.count else { multisigTransactionSignaturesLabel.text = ""; return }
                    guard let minSignatures = (multisigAccountData!.minCosignatories == 0 || multisigAccountData!.minCosignatories == multisigAccountData!.cosignatories.count) ? multisigAccountData!.cosignatories.count : multisigAccountData!.minCosignatories else { multisigTransactionSignaturesLabel.text = ""; return }
                    
                    if multisigSignatures + 1 < minSignatures {
                        multisigTransactionSignaturesLabel.textColor = Constants.outgoingColor
                    } else {
                        multisigTransactionSignaturesLabel.textColor = Constants.incomingColor
                    }
                    multisigTransactionSignaturesLabel.text = "\(multisigSignatures + 1) of \(minSignatures)"
                    
                    var isSignedByActiveAccount = false
                    for multisigSignature in multisigTransaction!.signatures! where multisigSignature.signer == account!.publicKey {
                        isSignedByActiveAccount = true
                    }
                    if multisigTransaction!.signer == account!.publicKey || multisigSignatures == minSignatures {
                        isSignedByActiveAccount = true
                    }
                    
                    var isCosignatory = false
                    for cosignatory in multisigAccountData!.cosignatories where cosignatory.publicKey == account!.publicKey {
                        isCosignatory = true
                    }
                    
                    if isSignedByActiveAccount == false && isCosignatory {
                        actionsView.isHidden = false
                        multisigSignaturesTableViewBottomToSuperviewConstraint.isActive = false
                        actionsViewBottomToSuperviewConstraint.isActive = true
                    }
                    
                } else {
                    multisigTransactionSignaturesLabel.text = ""
                }
                
                var isSignedByActiveAccount = false
                for multisigSignature in multisigTransaction!.signatures! where multisigSignature.signer == account!.publicKey {
                    isSignedByActiveAccount = true
                }
                if multisigTransaction!.signer == account!.publicKey {
                    isSignedByActiveAccount = true
                }
                
                if isSignedByActiveAccount {
                    actionsView.isHidden = true
                    multisigSignaturesTableViewBottomToSuperviewConstraint.isActive = true
                }
                
            default:
                break
            }
            
            
        default:
            break
        }
    }
    
    /// Fetches account data for the multisig account.
    private func fetchMultisigAccountData() {
        
        guard multisigTransaction != nil else { return }
        let importanceTransferTransaction = multisigTransaction!.innerTransaction as! ImportanceTransferTransaction
        
        NEMProvider.request(NEM.accountData(accountAddress: AccountManager.sharedInstance.generateAddress(forPublicKey: importanceTransferTransaction.signer))) { [weak self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    let multisigAccountData = try json.mapObject(AccountData.self)
                    
                    DispatchQueue.main.async {
                        
                        self?.multisigAccountData = multisigAccountData
                        self?.reloadTransactionDetails()
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
                        
                        self?.actionsView.isHidden = true
                        self?.multisigSignaturesTableViewBottomToSuperviewConstraint.isActive = true
                        
                        let alert = UIAlertController(title: "INFO".localized(), message: "TRANSACTION_ANOUNCE_SUCCESS".localized(), preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: { (action) -> Void in
                            alert.dismiss(animated: true, completion: nil)
                        }))
                        
                        self?.present(alert, animated: true, completion: nil)
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
        
        signMultisigTransactionButton.layer.cornerRadius = 10.0
    }
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func signMultisigTransaction(_ sender: UIButton) {
        
        if let multisigTransaction = multisigTransaction {
            switch multisigTransaction.innerTransaction.type {
            case .importanceTransferTransaction:
                
                let importanceTransferTransaction = multisigTransaction.innerTransaction as! ImportanceTransferTransaction
                
                let transactionVersion = 1
                let transactionTimeStamp = Date(timeIntervalSince1970: TimeManager.sharedInstance.currentNetworkTime)
                let transactionFee = 0.15
                let transactionDeadline = Int(TimeManager.sharedInstance.currentNetworkTime + Constants.transactionDeadline)
                let transactionSigner = account!.publicKey
                let transactionHash = multisigTransaction.metaData!.hash!
                let transactionMultisigAccountAddress = AccountManager.sharedInstance.generateAddress(forPublicKey: importanceTransferTransaction.signer)
                
                let multisigSignatureTransaction = MultisigSignatureTransaction(version: transactionVersion, timeStamp: transactionTimeStamp, fee: Double(transactionFee), deadline: transactionDeadline, signer: transactionSigner, otherHash: transactionHash, otherAccount: transactionMultisigAccountAddress)
                
                announceTransaction(multisigSignatureTransaction!)
                
            default :
                break
            }
        }
    }
}

extension MultisigImportanceTransferTransactionDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table View Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + (multisigTransaction?.signatures?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            guard multisigTransaction != nil else { return UITableViewCell() }
            
            let multisigSignatureTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MultisigSignatureTableViewCell") as! MultisigSignatureTableViewCell
            multisigSignatureTableViewCell.signatureSignerLabel.text = AccountManager.sharedInstance.generateAddress(forPublicKey: multisigTransaction!.signer).nemAddressNormalised()
            multisigSignatureTableViewCell.signatureStatusLabel.text = "Signed"
            multisigSignatureTableViewCell.signatureDetailLabel.text = "Issuer"
            multisigSignatureTableViewCell.signatureDateLabel.text = multisigTransaction!.timeStamp.format()
            
            return multisigSignatureTableViewCell
            
        } else if let multisigSignatureTransaction = multisigTransaction?.signatures![indexPath.row - 1] {
            
            let multisigSignatureTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MultisigSignatureTableViewCell") as! MultisigSignatureTableViewCell
            multisigSignatureTableViewCell.signatureSignerLabel.text = AccountManager.sharedInstance.generateAddress(forPublicKey: multisigSignatureTransaction.signer).nemAddressNormalised()
            multisigSignatureTableViewCell.signatureStatusLabel.text = "Signed"
            multisigSignatureTableViewCell.signatureDetailLabel.text = ""
            multisigSignatureTableViewCell.signatureDateLabel.text = multisigSignatureTransaction.timeStamp.format()
            
            if indexPath.row == multisigTransaction!.signatures?.count {
                multisigSignatureTableViewCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            }
            
            return multisigSignatureTableViewCell
            
        } else {
            return UITableViewCell()
        }
    }
}
