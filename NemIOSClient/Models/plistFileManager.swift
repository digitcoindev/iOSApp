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
        var data = fileManager.contentsAtPath(documents + "/NEMfolder/" + way)
        if var str = data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions()) {
            var dataManager :CoreDataManager = CoreDataManager()
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
            fileManager.removeItemAtPath(documents + "/NEMfolder/" + path, error: &error)
            return true
        }
    }
    
    final func refreshImportData() ->Bool {
        if var imports =  fileManager.contentsOfDirectoryAtPath(documents + "/NEMfolder", error: &error) {
            
            importFiles = NSMutableArray(array: imports)
            
            return true
        }
        else {
            println("No accounts found...")
            
            return false
        }
        
    }
    
    final func readErrorLog() ->String? {
        if fileManager.fileExistsAtPath(documents + "/NEMfolder") {
            //reading
            var text = String(contentsOfFile: documents + "/NEMfolder/error_logs", encoding: NSUTF8StringEncoding, error: nil)
            
            return text
        }
        
        return nil
    }
    
    final func writeErrorLog(str :String) {
        if(fileManager.fileExistsAtPath(documents + "/NEMfolder")) {
            var text :String = "\n"
            
            //reading
            let text2 = String(contentsOfFile: documents + "/NEMfolder/error_logs", encoding: NSUTF8StringEncoding, error: nil)
            
            text = text2! + text
             //writing
            text.writeToFile(documents + "/NEMfolder/error_logs", atomically: false, encoding: NSUTF8StringEncoding, error: nil)
        }
    }
    
    final func traceImportFolder() {
        if(!fileManager.fileExistsAtPath(documents + "/NEMfolder")) {
            println("Add import folder...")
            fileManager.createDirectoryAtPath(documents + "/NEMfolder", withIntermediateDirectories: false, attributes: nil, error: &error)
            fileManager.createFileAtPath(documents + "/NEMfolder/error_logs", contents: nil, attributes: nil)
        }
    }
    
    final func deleteImportAccount(name :String) -> Bool {
        
        if(!fileManager.fileExistsAtPath(documents + "/NEMfolder/" + name)) {
            println("Remove imported account")
            
            fileManager.removeItemAtPath(documents + "/NEMfolder/" + name, error: &error)
            
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
