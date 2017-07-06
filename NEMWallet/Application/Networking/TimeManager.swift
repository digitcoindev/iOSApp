//
//  TimeManager.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import Foundation
import SwiftyJSON

/**
    The time manager that synchronizes the application time with the time 
    of the NEM network. Those timestamps have to match in order to announce
    valid transactions to the NEM network. Use the timeStamp property to get
    the synchronized, valid timestamp.
 */
class TimeManager {
    
    // MARK: - Manager Properties
    
    /// The singleton for the time manager.
    open static let sharedInstance = TimeManager()
    
    /// The current timestamp, synchronized with the NEM network.
    open var timeStamp: Double {
        get {
            return nisTime + Date().timeIntervalSince(localTime)
        }
    }
    
    /// The time of the NEM network.
    fileprivate var nisTime = 0.0 {
        didSet {
            localTime = Date()
        }
    }
    
    /// The local time of the device.
    fileprivate var localTime = Date()
    
    // MARK: - Manager Methods
    
    /// Synchronizes the application time with the NEM network time.
    open func synchronizeTime() {
        
        NEMProvider.request(NEM.synchronizeTime) { [unowned self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    let responseJSON = JSON(data: response.data)
                    
                    self.nisTime = responseJSON["receiveTimeStamp"].doubleValue / 1000
                    
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
}
