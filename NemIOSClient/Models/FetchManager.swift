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
    private var _server :Server? = nil
    
    func update(completionHandler: (UIBackgroundFetchResult) -> Void){
        _apiManager.delegate = self
        _apiManager.timeOutIntervar = 60
        _completionHandler = completionHandler
        
        if let language = State.loadData?.currentLanguage {
            LocalizationManager.setLanguage(language)
        }
        
        let dataManager = CoreDataManager()
        _accounts = dataManager.getWallets()
        
        let servers = dataManager.getServers()
        
        for inServer in servers {
            _apiManager.heartbeat(inServer)
        }
    }
    
    func heartbeatResponceFromServer(server: Server, successed: Bool) {
        if _server == nil && successed{
            _server = server
            if !FetchManager._updatesStarted {
                self.fetchUpdate()
            }
            
            FetchManager._updatesStarted = true
        }
    }

    final func accountTransfersAllResponceWithTransactions(data: [TransactionPostMetaData]?) {
        guard let data = data else {
            NotificationManager.sheduleLocalNotificationAfter("NEM", body: "NO_RESPONCE_FROM_SERVER".localized(), interval: 1, userInfo: nil)
            _completionHandler?(.Failed)
            FetchManager._updatesStarted = false
            return
        }
        
        var transactions :[TransferTransaction] = []
        let publicKey = KeyGenerator.generatePublicKey(HashManager.AES256Decrypt(_account!.privateKey, key: State.loadData!.password!)!)

        if _account?.lastTransactionHash != nil && data.first?.hashString == _account?.lastTransactionHash! {
//            let message = String(format: "NO_NOTIFICATIONS".localized(), _account!.login)
//            NotificationManager.sheduleLocalNotificationAfter("NEM", body: message, interval: 1, userInfo: nil)
//            print(message)
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
            
            if transaction != nil {
                transactions.append(transaction!)
            }
        }
        
        if transactions.count > 0 {
            
            let login = _account!.login
            let text = "NOTIFICATION_MESSAGE".localized()
            let message = String(format: text, transactions.count, login)

            
            NotificationManager.sheduleLocalNotificationAfter("NEM", body: message, interval: 1, userInfo: nil)
            _account?.lastTransactionHash = data.first!.hashString
            _dataManager.commit()
        }
        
        fetchUpdate()
    }
    
    private func fetchUpdate() {
        guard let account = _accounts.first else {
            if !FetchManager._updatesStarted {

                _completionHandler?(.Failed)
            } else {
                _completionHandler?(.NewData)
            }
            FetchManager._updatesStarted = false
            return
        }
        
        guard let server = _server else {
            NotificationManager.sheduleLocalNotificationAfter("NEM", body: "NO_PRIMARY_SERVER".localized(), interval: 1, userInfo: nil)
            _completionHandler?(.Failed)
            FetchManager._updatesStarted = false
            return
        }
        
        _account = account
        _accounts.removeFirst()
        
        let address = AddressGenerator.generateAddressFromPrivateKey(HashManager.AES256Decrypt(account.privateKey, key: State.loadData!.password!)!)
        _apiManager.accountTransfersAll(server, account_address: address)
    }
}
