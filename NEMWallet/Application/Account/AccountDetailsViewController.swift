//
//  AccountDetailsViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

///
final class AccountDetailsViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    public var accountBalance = Double()
    public var accountFiatBalance = Double()
    
    // MARK: - View Controller Outlets

    @IBOutlet weak var accountTitleLabel: UILabel!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    @IBOutlet weak var accountFiatBalanceLabel: UILabel!
    @IBOutlet weak var accountAddressLabel: UILabel!
    @IBOutlet weak var accountImportanceScoreLabel: UILabel!
    @IBOutlet weak var accountVestedBalanceLabel: UILabel!
    @IBOutlet weak var accountPublicKeyLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
                
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.numberStyle = .currency

        accountTitleLabel.text = account?.title ?? ""
        accountBalanceLabel.text = "\(accountBalance.format()) XEM"
        accountFiatBalanceLabel.text = numberFormatter.string(from: accountFiatBalance as NSNumber)
        accountAddressLabel.text = account?.address.nemAddressNormalised() ?? ""
        accountImportanceScoreLabel.text = ""
        accountVestedBalanceLabel.text = ""
        accountPublicKeyLabel.text = account?.publicKey.nemKeyNormalized() ?? ""
    }
}
