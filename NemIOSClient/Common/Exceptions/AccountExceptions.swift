//
//  AccountExceptions.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation

/**
 
 */
public enum Result: ErrorType {
    case Success
    case Failure
}

/**
 
 */
public enum AccountTitleValidation: ErrorType {
    case Empty
}