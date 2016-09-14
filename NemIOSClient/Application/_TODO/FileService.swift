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
    case fileAlreadyExist
    case fileNotExist
    case unsupportedFileName
    case failed
    case successed
}

protocol FileServiceProtocol
{
    func createFileWithName(_ name: String, data: Data, responce: ((_ state: FileServiceResponceState) -> Void)?)
    func deleteFileWithName(_ name: String, responce: ((_ state: FileServiceResponceState) -> Void)?)
    func renameFile(_ name: String, toName: String, responce: ((_ state: FileServiceResponceState) -> Void)?)
}

class FileService: FileServiceProtocol
{
    fileprivate let _manager :FileManager = FileManager()
    fileprivate let _documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    
    func createFileWithName(_ name: String, data: Data, responce: ((_ state: FileServiceResponceState) -> Void)?)
    {
        if !_validateFieName(name)
        {
            responce?(FileServiceResponceState.unsupportedFileName)
            return
        }
        
        let path = name.path()
        if _manager.fileExists(atPath: path)
        {
            responce?(FileServiceResponceState.fileAlreadyExist)
        }
        else
        {
            try? data.write(to: URL(fileURLWithPath: path), options: [.atomic])
            responce?(FileServiceResponceState.successed)
        }
    }
    
    func deleteFileWithName(_ name: String, responce: ((_ state: FileServiceResponceState) -> Void)?)
    {
        if !_validateFieName(name)
        {
            responce?(FileServiceResponceState.unsupportedFileName)
            return
        }
        
        let path = name.path()
        if _manager.fileExists(atPath: path)
        {
            try! _manager.removeItem(atPath: path)
            responce?(FileServiceResponceState.successed)
        }
        else
        {
            responce?(FileServiceResponceState.fileNotExist)
        }
    }
    
    func fileExist(_ name: String)-> Bool
    {
        if !_validateFieName(name)
        {
            return false
        }
        
        return _manager.fileExists(atPath: name.path())
    }
    
    func renameFile(_ name: String, toName: String, responce: ((_ state: FileServiceResponceState) -> Void)?)
    {
        if !_validateFieName(name) || !_validateFieName(toName)
        {
            responce?(FileServiceResponceState.unsupportedFileName)
            return
        }
        
        if _manager.fileExists(atPath: name.path())
        {
            if _manager.fileExists(atPath: toName.path())
            {
                responce?(FileServiceResponceState.fileAlreadyExist)
            }
            else
            {
                try! _manager.moveItem(atPath: name.path(), toPath: toName.path())
                responce?(FileServiceResponceState.successed)
            }
        }
        else
        {
            responce?(FileServiceResponceState.fileNotExist)
        }
    }
    
    //MARK: Private Methods
    
    fileprivate func _validateFieName(_ name: String)->Bool
    {
        let validExtantions = [".png", ".mov"]
        for ext in validExtantions
        {
            let stringRegEx = "\\b[A-Za-z]*(\\\(ext))\\b"
            let range = name.range(of: stringRegEx, options:.regularExpression)
            
            if range != nil {return true}
        }
        
        return false
    }
}
