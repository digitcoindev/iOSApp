//
//  Server.swift
//  NemIOSClient
//
//  Created by Bodya Bilas on 24.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import Foundation
import CoreData

class Server: NSManagedObject
{

    @NSManaged var name: String
    @NSManaged var address: String
    @NSManaged var port: String

    class func createInManagedObjectContext(moc: NSManagedObjectContext, name: String, address: String, port: String) -> Server
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Server", inManagedObjectContext: moc) as Server
        newItem.name = name
        newItem.address = address
        newItem.port = port
        
        return newItem
    }
}
