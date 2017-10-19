//
//  MultisigTransferTransactionDetailsViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

///
final class MultisigTransferTransactionDetailsViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    public var accountBalance = Double()
    public var accountFiatBalance = Double()
    public var multisigTransaction: MultisigTransaction?
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var accountTitleLabel: UILabel!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    @IBOutlet weak var accountFiatBalanceLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var transactionTypeLabel: UILabel!
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
    @IBOutlet weak var signMultisigTransactionButton: UIButton!
    @IBOutlet weak var multisigSignaturesTableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAppearance()
        reloadTransactionDetails()
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
        
        accountTitleLabel.text = account?.title ?? ""
        accountBalanceLabel.text = "\(accountBalance.format()) XEM"
        accountFiatBalanceLabel.text = numberFormatter.string(from: accountFiatBalance as NSNumber)
        
        guard multisigTransaction != nil else { return }
        
        switch multisigTransaction!.type {
        case .multisigTransaction:
            
            switch multisigTransaction!.innerTransaction.type {
            case .transferTransaction:
                
                let transferTransaction = multisigTransaction!.innerTransaction as! TransferTransaction
                
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
                transactionBlockHeightLabel.text = transferTransaction.metaData?.height != nil ? "\(transferTransaction.metaData!.height!)" : ""
                transactionHashLabel.text = "\(transferTransaction.metaData?.hash ?? "")"
                multisigTransactionHashLabel.text = "\(multisigTransaction?.metaData?.multisigHash ?? "")"
                
            default:
                break
            }
            
            
        default:
            break
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
        return multisigTransaction?.signatures?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let multisigSignatureTransaction = multisigTransaction?.signatures![indexPath.row] {
            
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
