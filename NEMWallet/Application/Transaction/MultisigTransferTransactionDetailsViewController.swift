//
//  MultisigTransferTransactionDetailsViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit
import SwiftyJSON

///
final class MultisigTransferTransactionDetailsViewController: UIViewController {
    
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
    @IBOutlet weak var signerLabel: UILabel!
    @IBOutlet weak var transactionSignerLabel: UILabel!
    @IBOutlet weak var transactionRecipientLabel: UILabel!
    @IBOutlet weak var transactionAmountLabel: UILabel!
    @IBOutlet weak var transactionFeeLabel: UILabel!
    @IBOutlet weak var transactionMessageLabel: UILabel!
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
            case .transferTransaction:
                
                let transferTransaction = multisigTransaction!.innerTransaction as! TransferTransaction
                
                informationView.isHidden = true
                transactionTypeLabelTopToInformationViewConstraint.isActive = false
                transactionTypeLabelTopToSuperviewConstraint.isActive = true
                
                transactionTypeLabel.text = transferTransaction.transferType == .incoming ? "Incoming Multisig Transaction" : "Outgoing Multisig Transaction"
                transactionDateLabel.text = transferTransaction.timeStamp.format()
                signerLabel.text = "From Multisig Account"
                transactionSignerLabel.text = AccountManager.sharedInstance.generateAddress(forPublicKey: transferTransaction.signer).nemAddressNormalised()
                transactionRecipientLabel.text = transferTransaction.recipient.nemAddressNormalised()
                
                if transferTransaction.transferType == .incoming {
                    transactionAmountLabel.text = "+\(transferTransaction.amount.format()) XEM"
                    transactionAmountLabel.textColor = Constants.incomingColor
                } else if transferTransaction.transferType == .outgoing {
                    transactionAmountLabel.text = "-\(transferTransaction.amount.format()) XEM"
                    transactionAmountLabel.textColor = Constants.outgoingColor
                }
                
                transactionFeeLabel.text = "\(transferTransaction.fee.format()) XEM"
                transactionMessageLabel.text = transferTransaction.message?.message ?? ""
                transactionBlockHeightLabel.text = transferTransaction.metaData?.height != nil ? "\(transferTransaction.metaData!.height!)" : "Unconfirmed"
                transactionHashLabel.text = "\(transferTransaction.metaData?.hash ?? "-")"
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
        let transferTransaction = multisigTransaction!.innerTransaction as! TransferTransaction
        
        NEMProvider.request(NEM.accountData(accountAddress: AccountManager.sharedInstance.generateAddress(forPublicKey: transferTransaction.signer))) { [weak self] (result) in
            
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
    
    /// Updates the appearance of the view controller.
    private func updateAppearance() {
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        signMultisigTransactionButton.layer.cornerRadius = 10.0
    }
}

extension MultisigTransferTransactionDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
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
            
            return multisigSignatureTableViewCell
            
        } else {
            return UITableViewCell()
        }
    }
}
