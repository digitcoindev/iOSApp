import UIKit

class plistFileManager: NSObject
{
    var fileManager  : NSFileManager = NSFileManager()
    var documents : String = NSHomeDirectory().stringByAppendingString("/Documents")
    var error: NSError? = nil
    
    var uiData : NSMutableDictionary = NSMutableDictionary()
    var importFiles :NSMutableArray = NSMutableArray()

    override init() {
        super.init()
        
        uiData = NSMutableDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("UIConfig", ofType: "plist")!)!
        
        traceImportFolder()
        refreshImportData()
        
        
     }
    
    // Import Accounts

    final func getImportedAccounts() -> NSMutableArray {
        return importFiles
    }
    
    func validatePair(way :String , password :String) -> Bool {
        let data = fileManager.contentsAtPath(documents + "/NEMfolder/" + way)
        if let str = data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions()) {
            if(HashManager.AES256Decrypt(str, key: password) == way) {
                return true
            }
        }
        
        return false
    }
    
    final func removeFileAtPath(path :String)->Bool {
        if(!fileManager.fileExistsAtPath(documents + "/NEMfolder/" + path)) {
            return false
        }
        else {
            do {
                try fileManager.removeItemAtPath(documents + "/NEMfolder/" + path)
            } catch let error1 as NSError {
                error = error1
            }
            return true
        }
    }
    
    final func refreshImportData() ->Bool {
        do {
            let imports =  try fileManager.contentsOfDirectoryAtPath(documents + "/NEMfolder")
            
            importFiles = NSMutableArray(array: imports)
            
            return true
        } catch let error1 as NSError {
            error = error1
            print("No accounts found...")
            
            return false
        }
        
    }
    
    final func readErrorLog() ->String? {
        if fileManager.fileExistsAtPath(documents + "/NEMfolder") {
            //reading
            let text = try? String(contentsOfFile: documents + "/NEMfolder/error_logs", encoding: NSUTF8StringEncoding)
            
            return text
        }
        
        return nil
    }
    
    final func writeErrorLog(str :String) {
        if(fileManager.fileExistsAtPath(documents + "/NEMfolder")) {
            var text :String = "\n"
            
            //reading
            let text2 = try? String(contentsOfFile: documents + "/NEMfolder/error_logs", encoding: NSUTF8StringEncoding)
            
            text = text2! + text
            do {
                //writing
                try text.writeToFile(documents + "/NEMfolder/error_logs", atomically: false, encoding: NSUTF8StringEncoding)
            } catch _ {
            }
        }
    }
    
    final func traceImportFolder() {
        if(!fileManager.fileExistsAtPath(documents + "/NEMfolder")) {
            print("Add import folder...")
            do {
                try fileManager.createDirectoryAtPath(documents + "/NEMfolder", withIntermediateDirectories: false, attributes: nil)
            } catch let error1 as NSError {
                error = error1
            }
            fileManager.createFileAtPath(documents + "/NEMfolder/error_logs", contents: nil, attributes: nil)
        }
    }
    
    final func deleteImportAccount(name :String) -> Bool {
        
        if(!fileManager.fileExistsAtPath(documents + "/NEMfolder/" + name)) {
            print("Remove imported account")
            
            do {
                try fileManager.removeItemAtPath(documents + "/NEMfolder/" + name)
            } catch let error1 as NSError {
                error = error1
            }
            
            return true
        }
        else {
            return false
        }
        
    }
    
    //UIConfig
    
    final func getMenuItems() -> NSMutableArray {
        return uiData.objectForKey("mainMenu") as! NSMutableArray
    }
    
    //GENERAL
    
    final func commit() {
        uiData.writeToFile(NSBundle.mainBundle().pathForResource("UIConfig", ofType: "plist")!, atomically: true)
    }
    
}
