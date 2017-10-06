//
//  AccountDetailsViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit
import SwiftyJSON

///
final class AccountDetailsViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    public var accountBalance = Double()
    public var accountFiatBalance = Double()
    public var accountData: AccountData?
    
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
    @IBOutlet weak var createBackupButton: UIButton!
    @IBOutlet weak var shareAccountDetailsButton: UIButton!
    
    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAppearance()
        reloadAccountDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchAccountData()
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Reloads all account details with the newest data.
    private func reloadAccountDetails() {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.numberStyle = .currency
        
        accountTitleLabel.text = account?.title ?? ""
        accountBalanceLabel.text = "\(accountBalance.format()) XEM"
        accountFiatBalanceLabel.text = numberFormatter.string(from: accountFiatBalance as NSNumber)
        accountAddressLabel.text = account?.address.nemAddressNormalised() ?? ""
        accountPublicKeyLabel.text = account?.publicKey.nemKeyNormalized() ?? ""
        
        if accountData?.importance != nil && accountData?.vestedBalance != nil {
            accountImportanceScoreLabel.text = "\((accountData!.importance! * 10000).format(maximumFractionDigits: 2)) ‱"
            accountVestedBalanceLabel.text = "\(accountData!.vestedBalance.format()) XEM"
        } else {
            accountImportanceScoreLabel.text = ""
            accountVestedBalanceLabel.text = ""
        }
    }
    
    /// Fetches the importance score and vested balance for the account.
    private func fetchAccountData() {
        
        guard account != nil else { return }
        
        NEMProvider.request(NEM.accountData(accountAddress: account!.address)) { [weak self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    let accountData = try json.mapObject(AccountData.self)
                    
                    DispatchQueue.main.async {
                        
                        self?.accountData = accountData
                        self?.reloadAccountDetails()
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
        
        createBackupButton.layer.cornerRadius = 10.0
        shareAccountDetailsButton.layer.cornerRadius = 10.0
    }
}
