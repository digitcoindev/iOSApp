//
//  State.swift
//  NemIOSClient
//
//  Created by Bodya Bilas on 22.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit


class State: NSObject
{
    struct Store
        {
        static var previousVC : String = String()
        static var currentWallet : Int = -1
        static var currentServer : Int = -1
    }
    
    class var previousVC: String
        {
        get { return State.Store.previousVC }
        set { State.Store.previousVC = newValue }
    }
    
    class var currentWallet: Int
        {
        get { return State.Store.currentWallet }
        set { State.Store.currentWallet = newValue }
    }
    class var currentServer: Int
        {
        get { return State.Store.currentWallet }
        set { State.Store.currentWallet = newValue }
    }
    
    override init()
    {
        
    }
    
}
