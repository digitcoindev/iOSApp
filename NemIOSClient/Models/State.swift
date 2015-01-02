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
        static var fromVC : String = String()
        static var toVC : String = String()
        static var currentWallet : Int = -1
        static var currentServer : Int = -1
    }
    
    class var fromVC: String
        {
        get { return State.Store.fromVC }
        set { State.Store.fromVC = newValue }
    }
    
    class var toVC: String
        {
        get { return State.Store.toVC }
        set { State.Store.toVC = newValue }
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
