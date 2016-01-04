//
//  FetchManager.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 28.12.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class FetchManager: NSObject, APIManagerDelegate {
    private var _accounts :[Wallet] = []
    private var _completionHandler :((UIBackgroundFetchResult) -> Void)? = nil
    private let _dataManager = CoreDataManager()
    private let _apiManager = APIManager()
    private var _account :Wallet? = nil
    private static var _updatesStarted = false
    
    func update(completionHandler: (UIBackgroundFetchResult) -> Void){
        _apiManager.delegate = self
        _apiManager.timeOutIntervar = 60
        _completionHandler = completionHandler
        
        if let language = State.loadData?.currentLanguage {
            LocalizationManager.setLanguage(language)
        }
        
        let dataManager = CoreDataManager()
        _accounts = dataManager.getWallets()
        
        if !FetchManager._updatesStarted {
            self.fetchUpdate()
        }
        
        FetchManager._updatesStarted = true
    }

    final func accountTransfersAllResponceWithTransactions(data: [TransactionPostMetaData]?) {
        guard let data = data else {
            NotificationManager.sheduleLocalNotificationAfter("NEM", body: "NO_RESPONCE_FROM_SERVER".localized(), interval: 1, userInfo: nil)
            _completionHandler?(.Failed)
            FetchManager._updatesStarted = false
            return
        }
        
        var transactions :[TransferTransaction] = []
        let publicKey = KeyGenerator.generatePublicKey(HashManager.AES256Decrypt(_account!.privateKey, key: _account!.password)!)

        if _account?.lastTransactionHash != nil && data.first?.hashString == _account?.lastTransactionHash! {
            NotificationManager.sheduleLocalNotificationAfter("NEM", body: String(format: "NO_NOTIFICATIONS".localized(), _account!.login), interval: 1, userInfo: nil)
            fetchUpdate()
            return
        }
        
        for inData in data {
            var transaction :TransferTransaction? = nil
            switch (inData.type) {
            case transferTransaction :
                transaction = inData as? TransferTransaction
            case multisigTransaction:
                
                let multisigT  = inData as! MultisigTransaction
                
                switch(multisigT.innerTransaction.type) {
                case transferTransaction :
                    transaction = multisigT.innerTransaction as? TransferTransaction
                default:
                    break
                }
            default:
                break
            }
            
            
            if transaction?.signer == publicKey {
                continue
            }
            
            if _account?.lastTransactionHash != nil && inData.hashString == _account?.lastTransactionHash! {
                if transactions.count == 0 {
                    NotificationManager.sheduleLocalNotificationAfter("NEM", body: String(format: "NO_NOTIFICATIONS".localized(), _account!.login), interval: 1, userInfo: nil)
                }
                
                break
            }
            
            if transaction != nil {
                transactions.append(transaction!)
            }
        }
        
        if transactions.count > 0 {
            NotificationManager.sheduleLocalNotificationAfter("NEM", body:
                String(format: "NOTIFICATION_MESSAGE".localized(), _account!.login, transactions.count), interval: 1, userInfo: nil)
            _account?.lastTransactionHash = data.first!.hashString
            _dataManager.commit()
        }
        
        fetchUpdate()
    }
    
    private func fetchUpdate() {
        guard let account = _accounts.first else {
            if !FetchManager._updatesStarted {
                NotificationManager.sheduleLocalNotificationAfter("NEM", body: "NO_ACCOUNTS".localized(), interval: 1, userInfo: nil)
                _completionHandler?(.Failed)
            } else {
                _completionHandler?(.NewData)
            }
            FetchManager._updatesStarted = false
            return
        }
        
        guard let server = State.currentServer else {
            NotificationManager.sheduleLocalNotificationAfter("NEM", body: "NO_PRIMARY_SERVER".localized(), interval: 1, userInfo: nil)
            _completionHandler?(.Failed)
            FetchManager._updatesStarted = false
            return
        }
        
        _account = account
        _accounts.removeFirst()
        
        let address = AddressGenerator.generateAddressFromPrivateKey(HashManager.AES256Decrypt(account.privateKey, key: account.password)!)
        _apiManager.accountTransfersAll(server, account_address: address)
    }
}
