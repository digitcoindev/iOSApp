//
//  Constants.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

/**
    Holds all constants of the application.
    Change these values to tweak the application.
 */
struct Constants {
    
    // MARK: - Network Version

    /**
        Change this constant to switch between the mainnet and testnet.
        The application only supports one network at a time.
     
        Available options:
        - mainNetwork
        - testNetwork
     */
    static let activeNetwork = mainNetwork

    static let testNetwork: UInt8 = 152
    static let mainNetwork: UInt8 = 104

    // MARK: - Timing

    /**
        The unix timestamp for the creation of the genesis block, used to calculate the 
        right timestamps for blocks, transactions, etc.
     */
    static let genesisBlockTime = 1427587585.0

    /// The deadline for new transactions after which they will get invalidated, if their not yet included in a block.
    static let transactionDeadline = 21600.0

    /// The interval at which content (transactions, account balance, etc.) should get refreshed.
    static let updateInterval: TimeInterval = 30

    // MARK: - QR Structure

    /**
        The versions of QR codes, which the application supports.
        Testnet QR codes are of version 1, mainnet QR codes of version 2.
     */
    static let qrVersion = activeNetwork == testNetwork ? 1 : 2
    
    // MARK: - Coloring
    
    static let nemBlueColor = UIColor(red: 43/255, green: 182/255, blue: 237/255, alpha: 1.0)
    static let nemLightBlueColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 0.1)
    static let nemOrangeColor = UIColor(red: 255/255, green: 163/255, blue: 0/255, alpha: 1.0)
    static let nemLightOrangeColor = UIColor(red: 255/255, green: 163/255, blue: 0/255, alpha: 0.1)
    static let incomingColor = UIColor(red: 0/255, green: 188/255, blue: 0/255, alpha: 1.0)
    static let outgoingColor = UIColor(red: 203/255, green: 0/255, blue: 0/255, alpha: 1.0)
}
