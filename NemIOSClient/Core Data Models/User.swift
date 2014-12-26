//
//  User.swift
//  NemIOSClient
//
//  Created by Bodya Bilas on 23.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject
{

    @NSManaged var pin: String
    @NSManaged var state: String

    class func createInManagedObjectContext(moc: NSManagedObjectContext, pin1: String, state1: String) -> User
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: moc) as User
        newItem.pin = pin1
        newItem.state = state1
        
        return newItem
    }
}
