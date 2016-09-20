//
//  AddressBookManager.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import Contacts

/**
    The address book manager singleton used to perform all kinds of actions in 
    relationship with the address book or a contact. Use this managers available 
    methods instead of writing your own logic.
 */
open class AddressBookManager {
    
    // MARK: - Manager Properties

    /// The singleton for the address book manager.
    open static let sharedInstance = AddressBookManager()
    
    ///
    fileprivate var contactStore = CNContactStore()
    
    // MARK: - Public Manager Methods
    
    /**
 
     */
    open func contacts(_ completion: @escaping (_ contacts: [CNContact]) -> Void) {
        
        var contacts = [CNContact]()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.requestAccess { (accessGranted) -> Void in
                if accessGranted {
                    
                    let containerIdentifier = self.contactStore.defaultContainerIdentifier()
                    let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey]
                    let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerIdentifier)
                    
                    do {
                        contacts = try self.contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as [CNKeyDescriptor])
                        
                    } catch let error as NSError {
                        
                        DispatchQueue.main.async {
                            print(error)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    return completion(contacts)
                }
            }
        }
    }
    
    // MARK: - Private Manager Methods
    
    /**
 
     */
    fileprivate func requestAccess(_ completion: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized:
            return completion(true)
            
        case .denied, .notDetermined:
            contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    return completion(access)
                } else {
                    return completion(false)
                }
            })
            
        default:
            completion(false)
        }
    }
}
    
    
    
    
    



    
//    //MARK: - Inizializers
//    
//    final class func create() {
//        refresh(nil)
//    }
//    
//    //MARK: - Controllers
//    
//    final class func addContact(contact :CNMutableContact, responce: (CNMutableContact? -> Void)?)
//    {
//        let state = _actionWithAccess({ () -> Void in
//            
//            let saveRequest = CNSaveRequest()
//            saveRequest.addContact(contact, toContainerWithIdentifier:nil)
//            do {
//                try contactStore.executeSaveRequest(saveRequest)
//            } catch let error as NSError {
//                print(error)
//                responce?(nil)
//                return
//            }
//            
//            responce?(contact)
//        })
//        
//        if !(state ?? true) {
//            responce?(nil)
//        }
//    }
//    
//    final class func updateContact(contact :CNMutableContact, responce: (CNMutableContact? -> Void)?)
//    {
//        let state = _actionWithAccess({ () -> Void in
//            
//            let saveRequest = CNSaveRequest()
//            saveRequest.updateContact(contact)
//            do {
//                try contactStore.executeSaveRequest(saveRequest)
//            } catch let error as NSError {
//                print(error)
//                responce?(nil)
//                return
//            }
//            
//            responce?(contact)
//        })
//        
//        if !(state ?? true) {
//            responce?(nil)
//        }
//    }
//    
//    
//    final class func deleteContact(contact :CNContact, responce: (Void -> Void)?) {
//        let state = _actionWithAccess({ () -> Void in
//            let saveRequest = CNSaveRequest()
//            saveRequest.deleteContact(contact.mutableCopy() as! CNMutableContact)
//            do {
//                try contactStore.executeSaveRequest(saveRequest)
//            } catch let error as NSError {
//                print(error)
//                responce?()
//                return
//            }
//            responce?()
//        })
//        
//        if !(state ?? true) {
//            responce?()
//        }
//    }
//
//    
//    final private class func _sort(contacts :[CNContact])
//    {
//        var nemContacts:[CNContact] = []
//        var simpleContacts:[CNContact] = []
//        
//        for contact in contacts {
//            let emails: [CNLabeledValue] = contact.emailAddresses
//            
//            var isConnectedNEMAddress = false
//            
//            for email in emails {
//                if email.label == "NEM" {
//                    isConnectedNEMAddress = true
//                }
//            }
//            
//            if isConnectedNEMAddress {
//                nemContacts.append(contact)
//            } else {
//                simpleContacts.append(contact)
//            }
//        }
//        
//        Store.simpleContacts = simpleContacts
//        Store.nemContacts = nemContacts
//    }
