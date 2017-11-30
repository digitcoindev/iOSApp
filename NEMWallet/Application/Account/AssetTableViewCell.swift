//
//  AssetTableViewCell.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

/// A table view cell representing an asset on the asset view controller.
final class AssetTableViewCell: UITableViewCell {
    
    // MARK: - Cell Outlets
    
    @IBOutlet weak var assetNameLabel: UILabel!
    @IBOutlet weak var assetBalanceLabel: UILabel!
}
