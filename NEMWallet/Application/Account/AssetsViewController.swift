//
//  AssetsViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit
import SwiftyJSON

///
final class AssetsViewController: UITableViewController {
    
    // MARK: - View Controller Properties
    
    ///
    public var accountBalance = Double()
    
    ///
    public var accountFiatBalance = Double()
    
    ///
    public var account: Account?
    
    ///
    fileprivate var ownedAssets = [Mosaic]()
    
    ///
    fileprivate var ownedAssetDefinitions = [MosaicDefinition]()
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadAssetsOverview()
        updateAppearance()
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Reloads the assets overview with the newest data.
    private func reloadAssetsOverview() {
        
        if account != nil {
            fetchOwnedAssets()
            fetchOwnedAssetDefinitions()
        }
    }
    
    ///
    private func fetchOwnedAssets() {
        
        NEMProvider.request(NEM.ownedMosaics(accountAddress: account!.address)) { [weak self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    var ownedAssets = try json["data"].mapArray(Mosaic.self)
                    
                    DispatchQueue.main.async {
                        
                        for asset in ownedAssets where asset.name == "xem" {
                            ownedAssets.remove(at: ownedAssets.index(where: { $0.name == asset.name })!)
                        }
                        
                        self?.ownedAssets = ownedAssets
                        self?.tableView.reloadData()
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
    
    ///
    private func fetchOwnedAssetDefinitions() {
        
        NEMProvider.request(NEM.ownedMosaicDefinitions(accountAddress: account!.address)) { [weak self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    let ownedAssetDefinitions = try json["data"].mapArray(MosaicDefinition.self)
                    
                    DispatchQueue.main.async {
                        
                        self?.ownedAssetDefinitions = ownedAssetDefinitions
                        self?.tableView.reloadData()
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
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
    }
}

extension AssetsViewController {
    
    // MARK: - Table View Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ownedAssets.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.numberStyle = .currency
        
        if indexPath.row == 0 {
            
            let accountSummaryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AccountSummaryTableViewCell") as! AccountSummaryTableViewCell
            accountSummaryTableViewCell.accountTitleLabel.text = account?.title ?? ""
            accountSummaryTableViewCell.accountBalanceLabel.text = "\(accountBalance.format()) XEM"
            accountSummaryTableViewCell.accountFiatBalanceLabel.text = numberFormatter.string(from: accountFiatBalance as NSNumber)
            
            return accountSummaryTableViewCell
            
        } else {
            
            let asset = ownedAssets[indexPath.row - 1]

            for assetDefinition in ownedAssetDefinitions where assetDefinition.namespace == asset.namespace && assetDefinition.name == asset.name {
                
                let assetTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AssetTableViewCell") as! AssetTableViewCell
                assetTableViewCell.assetNameLabel.text = "\(asset.namespace!):\(asset.name!)"
                assetTableViewCell.assetBalanceLabel.text = (asset.quantity / Double(truncating: pow(10, assetDefinition.divisibility) as NSNumber)).format()
                
                return assetTableViewCell
            }
            
            return UITableViewCell()
        }
    }
}
