//
//  AddressBookManager.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import Contacts
import GCDKit

/**
    The address book manager singleton used to perform all kinds of actions in 
    relationship with the address book or a contact. Use this managers available 
    methods instead of writing your own logic.
 */
public class AddressBookManager {
    
    // MARK: - Manager Properties

    /// The singleton for the address book manager.
    public static let sharedInstance = AddressBookManager()
    
    ///
    private var contactStore = CNContactStore()
    
    // MARK: - Public Manager Methods
    
    /**
 
     */
    public func contacts(completion: (contacts: [CNContact]) -> Void) {
        
        var contacts = [CNContact]()
        
        GCDQueue.UserInitiated.async {
            
            self.requestAccess { (accessGranted) -> Void in
                if accessGranted {
                    
                    let containerIdentifier = self.contactStore.defaultContainerIdentifier()
                    let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey]
                    let predicate = CNContact.predicateForContactsInContainerWithIdentifier(containerIdentifier)
                    
                    do {
                        contacts = try self.contactStore.unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)
                        
                    } catch let error as NSError {
                        
                        GCDQueue.Main.async {
                            print(error)
                        }
                    }
                }
                
                GCDQueue.Main.async {
                    return completion(contacts: contacts)
                }
            }
        }
    }
    
    // MARK: - Private Manager Methods
    
    /**
 
     */
    private func requestAccess(completion: (accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            return completion(accessGranted: true)
            
        case .Denied, .NotDetermined:
            contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    return completion(accessGranted: access)
                } else {
                    return completion(accessGranted: false)
                }
            })
            
        default:
            completion(accessGranted: false)
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
