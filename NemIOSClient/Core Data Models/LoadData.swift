//
//  LoadData.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 23.12.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import Foundation
import CoreData


class LoadData: NSManagedObject {

    @NSManaged var lastTransactionHash: String?
    @NSManaged var currentLanguage: String?
    @NSManaged var updateInterval: NSNumber?
    @NSManaged var touchId: NSNumber?
    @NSManaged var invoicePrefix: String?
    @NSManaged var invoicePostfix: String?
    @NSManaged var currentServer: Server?
    @NSManaged var currentWallet: Wallet?
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext) -> LoadData {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("LoadData", inManagedObjectContext: moc) as! LoadData
        
        
        return newItem
    }
}
