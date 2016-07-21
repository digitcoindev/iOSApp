//
//  FileService.swift
//  jigit
//
//  Created by Lyubomir Dominik on 30.10.15.
//  Copyright © 2015 dominik. All rights reserved.
//

import UIKit

enum FileServiceResponceState
{
    case FileAlreadyExist
    case FileNotExist
    case UnsupportedFileName
    case Failed
    case Successed
}

protocol FileServiceProtocol
{
    func createFileWithName(name: String, data: NSData, responce: ((state: FileServiceResponceState) -> Void)?)
    func deleteFileWithName(name: String, responce: ((state: FileServiceResponceState) -> Void)?)
    func renameFile(name: String, toName: String, responce: ((state: FileServiceResponceState) -> Void)?)
}

class FileService: FileServiceProtocol
{
    private let _manager :NSFileManager = NSFileManager()
    private let _documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    
    func createFileWithName(name: String, data: NSData, responce: ((state: FileServiceResponceState) -> Void)?)
    {
        if !_validateFieName(name)
        {
            responce?(state: FileServiceResponceState.UnsupportedFileName)
            return
        }
        
        let path = name.path()
        if _manager.fileExistsAtPath(path)
        {
            responce?(state: FileServiceResponceState.FileAlreadyExist)
        }
        else
        {
            data.writeToFile(path, atomically: true)
            responce?(state: FileServiceResponceState.Successed)
        }
    }
    
    func deleteFileWithName(name: String, responce: ((state: FileServiceResponceState) -> Void)?)
    {
        if !_validateFieName(name)
        {
            responce?(state: FileServiceResponceState.UnsupportedFileName)
            return
        }
        
        let path = name.path()
        if _manager.fileExistsAtPath(path)
        {
            try! _manager.removeItemAtPath(path)
            responce?(state: FileServiceResponceState.Successed)
        }
        else
        {
            responce?(state: FileServiceResponceState.FileNotExist)
        }
    }
    
    func fileExist(name: String)-> Bool
    {
        if !_validateFieName(name)
        {
            return false
        }
        
        return _manager.fileExistsAtPath(name.path())
    }
    
    func renameFile(name: String, toName: String, responce: ((state: FileServiceResponceState) -> Void)?)
    {
        if !_validateFieName(name) || !_validateFieName(toName)
        {
            responce?(state: FileServiceResponceState.UnsupportedFileName)
            return
        }
        
        if _manager.fileExistsAtPath(name.path())
        {
            if _manager.fileExistsAtPath(toName.path())
            {
                responce?(state: FileServiceResponceState.FileAlreadyExist)
            }
            else
            {
                try! _manager.moveItemAtPath(name.path(), toPath: toName.path())
                responce?(state: FileServiceResponceState.Successed)
            }
        }
        else
        {
            responce?(state: FileServiceResponceState.FileNotExist)
        }
    }
    
    //MARK: Private Methods
    
    private func _validateFieName(name: String)->Bool
    {
        let validExtantions = [".png", ".mov"]
        for ext in validExtantions
        {
            let stringRegEx = "\\b[A-Za-z]*(\\\(ext))\\b"
            let range = name.rangeOfString(stringRegEx, options:.RegularExpressionSearch)
            
            if range != nil {return true}
        }
        
        return false
    }
}
