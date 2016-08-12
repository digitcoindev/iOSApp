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
public enum AccountImportValidation: ErrorType {
    case ValueMissing
    case VersionNotMatching
    case DataTypeNotMatching
    case NoPasswordProvided
    case WrongPasswordProvided
    case AccountAlreadyPresent(accountTitle: String)
    case InvalidPrivateKey
    case Other
}