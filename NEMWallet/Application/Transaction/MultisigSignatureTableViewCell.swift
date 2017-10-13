//
//  MultisigSignatureTableViewCell.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

/// A table view cell representing a multisig signature in the multisig transfer transaction details.
final class MultisigSignatureTableViewCell: UITableViewCell {
    
    // MARK: - Cell Outlets
    
    @IBOutlet weak var signatureSignerLabel: UILabel!
    @IBOutlet weak var signatureStatusLabel: UILabel!
    @IBOutlet weak var signatureDetailLabel: UILabel!
    @IBOutlet weak var signatureDateLabel: UILabel!
}
