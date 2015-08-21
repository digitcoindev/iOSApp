//
//  CorrespondentNew.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 18.08.15.
//  Copyright (c) 2015 Artygeek. All rights reserved.
//

import UIKit

class Correspondent: NSObject {
    var public_key: String = ""
    var address: String = ""
    var name: String = ""
    var transaction :TransferTransaction!
    
    class func generateCorespondetsFromTransactions(transactions :[TransferTransaction]) -> [Correspondent]{
        var correspondents :[Correspondent] = []
        
        var privateKey = ""
        var account_address = ""
        
        if State.currentWallet != nil {
            privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
            account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey)
        }
        
        for transaction in transactions {
            var find = false
            
            var signerAddress = AddressGenerator.generateAddress(transaction.signer)
            
            for correspondent in correspondents {
                if correspondent.address == signerAddress && signerAddress != account_address {
                    find = true
                    break
                } else if correspondent.address == transaction.recipient && transaction.recipient != account_address {
                    find = true
                    break
                } else if correspondent.address == signerAddress && correspondent.address == transaction.recipient {
                    find = true
                    break
                }
            }
            
            if !find {
                var correspondent = Correspondent()
                correspondent.address = (account_address != signerAddress) ? signerAddress : transaction.recipient
                correspondent.name = correspondent.address
                correspondent.transaction = transaction
                correspondents.append(correspondent)
            }
        }
        return correspondents
    } 
}
