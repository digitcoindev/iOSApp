//
//  TimeManager.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import GCDKit
import SwiftyJSON

/**
    The time manager that synchronizes the time of the application 
    with the NIS time.
 */
public class TimeManager {
    
    // MARK: - Manager Properties
    
    /// The singleton for the time manager.
    public static let sharedInstance = TimeManager()
    
    /// The time of the NEM network.
    private var nisTime = 0.0 {
        didSet {
            localTime = NSDate()
        }
    }
    
    /// The local time of the device.
    private var localTime = NSDate()
    
    /// The current time stamp synchronized with the NEM network.
    public var timeStamp: Double {
        get {
            return nisTime + NSDate().timeIntervalSinceDate(localTime)
        }
    }
    
    // MARK: - Manager Methods
    
    /// Synchronizes the application time with the NEM network time.
    public func synchronizeTime() {
        
        nisProvider.request(NIS.SynchronizeTime) { [unowned self] (result) in
            
            switch result {
            case let .Success(response):
                
                do {
                    try response.filterSuccessfulStatusCodes()
                    let responseJSON = JSON(data: response.data)
                    
                    GCDQueue.Main.async {
                        
                        self.nisTime = responseJSON["receiveTimeStamp"].doubleValue / 1000
                    }
                    
                } catch {
                    
                    GCDQueue.Main.async {
                        
                        print("Failure: \(response.statusCode)")
                    }
                }
                
            case let .Failure(error):
                
                GCDQueue.Main.async {
                    
                    print(error)
                }
            }
        }
    }
}
