import UIKit
import AddressBook

class AddressBookManager: NSObject
{
    struct Store
    {
        static let addressBook : ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        static var isAllowed :Bool = false
        static var contacts :NSArray = NSArray()
    }
    
    final class var contacts :NSArray
    {
        get
        {
            return Store.contacts
        }
    }
    
    final class var addressBook :ABAddressBookRef
    {
        get
        {
        return Store.addressBook!
        }
    }
    
    final class var isAllowed :Bool
    {
        get
        {
            return Store.isAllowed
        }
    }
    
    final class func create()
    {
        ABAddressBookRequestAccessWithCompletion(Store.addressBook,
            {
                (granted : Bool, error: CFError!) -> Void in
                if granted == true
                {
                    Store.isAllowed = true
                    Store.contacts = ABAddressBookCopyArrayOfAllPeople(Store.addressBook).takeRetainedValue()
                }
        })
    }
    
    final class func refresh()
    {
        Store.contacts = ABAddressBookCopyArrayOfAllPeople(Store.addressBook).takeRetainedValue()
    }
}
