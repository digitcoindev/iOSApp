//
//  DatabaseManager.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import CoreStore

/**
    The database manager singleton used to interact with the core data database.
    This manager is utilizing the CoreStore framework.
    Use only this manager to interact with the database.
 */
public class DatabaseManager: NSObject {
    
    // MARK: - Manager Properties
    
    /// The singleton for the database manager.
    public static let sharedInstance = DatabaseManager()
    
    /// The data stack that manages all available stores.
    public let dataStack = DataStack(modelName: "NemIOSClientTEMP")
    
    // MARK: - Manager Lifecycle
    
    private override init() {
        super.init()
        synthesizeDatabaseManager()
    }
    
    // MARK: - Manager Helper Methods
    
    /// Synthesizes the database manager and adds all stores to the data stack.
    private func synthesizeDatabaseManager() {
        
        try! dataStack.addStorageAndWait(
            SQLiteStore(
                fileName: "NemIOSClientTEMP.sqlite",
                localStorageOptions: .RecreateStoreOnModelMismatch
            )
        )
    }
}