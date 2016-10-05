//
//  FetchManager.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 28.12.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class FetchManager: NSObject, APIManagerDelegate {
    fileprivate var _accounts :[Wallet] = []
    fileprivate var _completionHandler :((UIBackgroundFetchResult) -> Void)? = nil
//    private let _dataManager = CoreDataManager()
    fileprivate let _apiManager = APIManager()
    fileprivate var _account :Wallet? = nil
    fileprivate static var _updatesStarted = false
    fileprivate var _server :Server? = nil
    fileprivate var strongSelf: FetchManager? = nil
    
    func update(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        strongSelf = self
        _apiManager.delegate = strongSelf
        _apiManager.timeOutIntervar = 60
        _completionHandler = completionHandler
        
        if let language = State.loadData?.currentLanguage {
//            LocalizationManager.setLanguage(language)
        }
        
//        let dataManager = CoreDataManager()
//        _accounts = dataManager.getWallets()
        
//        let servers = dataManager.getServers()
        
//        for inServer in servers {
//            _apiManager.heartbeat(inServer)
//        }
    }
    
    func heartbeatResponceFromServer(_ server: Server, successed: Bool) {
        if _server == nil && successed{
            _server = server
            if !FetchManager._updatesStarted {
                self.fetchUpdate()
            }
            
            FetchManager._updatesStarted = true
        }
    }

    final func accountTransfersAllResponceWithTransactions(_ data: [TransactionPostMetaData]?) {
        guard let data = data else {
//            NotificationManager.sheduleLocalNotificationAfter("NEM", body: "NO_RESPONCE_FROM_SERVER".localized(), interval: 1, userInfo: nil)
            _completionHandler?(.failed)
            FetchManager._updatesStarted = false
            return
        }
        
        var transactions :[_TransferTransaction] = []
//        let publicKey = KeyGenerator.generatePublicKey(HashManager.AES256Decrypt(_account!.privateKey, key: State.loadData!.password!)!)

        print("Last transaction hash: " + (_account?.lastTransactionHash ?? "nil"))
        print("Current transaction hash: " + (data.first?.hashString ?? "nil"))
        if _account?.lastTransactionHash != nil && data.first?.hashString == _account?.lastTransactionHash! {
//            let message = String(format: "NO_NOTIFICATIONS".localized(), _account!.login)
//            NotificationManager.sheduleLocalNotificationAfter("NEM", body: message, interval: 1, userInfo: nil)
//            print(message)
            fetchUpdate()
            return
        }
        
        for inData in data {
            if inData.hashString == _account?.lastTransactionHash {
                break
            }
            
            var transaction :_TransferTransaction? = nil
            switch (inData.type) {
            case transferTransaction :
                transaction = inData as? _TransferTransaction
            case multisigTransaction:
                
                let multisigT  = inData as! _MultisigTransaction
                
                switch(multisigT.innerTransaction.type) {
                case transferTransaction :
                    transaction = multisigT.innerTransaction as? _TransferTransaction
                default:
                    break
                }
            default:
                break
            }
            
            
//            if transaction?.signer == publicKey {
//                continue
//            }
            
            if transaction != nil {
                transactions.append(transaction!)
            }
        }
        
        if transactions.count > 0 {
            
            let login = _account!.login
            let text = "NOTIFICATION_MESSAGE".localized()
            let message = String(format: text, transactions.count, login)

            
//            NotificationManager.sheduleLocalNotificationAfter("NEM", body: message, interval: 1, userInfo: nil)
            _account?.lastTransactionHash = data.first!.hashString
//            _dataManager.commit()
        }
        
        fetchUpdate()
    }
    
    fileprivate func fetchUpdate() {
        guard let account = _accounts.first else {
            if !FetchManager._updatesStarted {

                _completionHandler?(.failed)
            } else {
                _completionHandler?(.newData)
            }
            FetchManager._updatesStarted = false
            strongSelf = nil
            return
        }
        
        guard let server = _server else {
//            NotificationManager.sheduleLocalNotificationAfter("NEM", body: "NO_PRIMARY_SERVER".localized(), interval: 1, userInfo: nil)
            _completionHandler?(.failed)
            FetchManager._updatesStarted = false
            return
        }
        
        _account = account
        _accounts.removeFirst()
        
        let address = AddressGenerator.generateAddressFromPrivateKey(HashManager.AES256Decrypt(inputText: account.privateKey, key: State.loadData!.password!)!)
        _apiManager.accountTransfersAll(server, account_address: address)
    }
}
