//
//  ServerCustomVC.swift
//  NemIOSClient
//
//  Created by Dominik Lyubomyr on 16.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit

class ServerCustomVC: UIViewController
{
    @IBOutlet weak var serverName: UITextField!
    @IBOutlet weak var serverAddress: UITextField!
    @IBOutlet weak var serverPort: UITextField!
    
    let manager :plistFileManager = plistFileManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
    
    @IBAction func addServer(sender: AnyObject)
    {
        manager.addServer(serverName.text, address: serverAddress.text ,port: serverPort.text)
        serverAddress.text = ""
        serverName.text = ""
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    
}
