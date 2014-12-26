//
//  Wallet.swift
//  NemIOSClient
//
//  Created by Bodya Bilas on 24.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import Foundation
import CoreData

class Wallet: NSManagedObject
{

    @NSManaged var login: String
    @NSManaged var password: String

    class func createInManagedObjectContext(moc: NSManagedObjectContext, login: String, password: String) -> Wallet
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Wallet", inManagedObjectContext: moc) as Wallet
        newItem.login = login
        newItem.password = password
        
        return newItem
    }
}
