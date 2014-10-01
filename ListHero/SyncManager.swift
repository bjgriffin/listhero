//
//  SyncManager.swift
//  ListHero
//
//  Created by BJ Griffin on 9/19/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit
import CoreData

enum kObjectSync: Int {
    case kObjectSynced = 100, kObjectCreated, kObjectDeleted, kObjectUpdated
}

enum kEntityName: String {
    case entityList = "List", entityItem = "ListItem"
}

class SyncManager: NSObject {
    var coreDataManager = CoreDataManager.sharedInstance
    let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()

    class var sharedInstance : SyncManager {
        struct Static {
            static let instance : SyncManager = SyncManager()
        }
        return Static.instance
    }
    
    func sync() {
        let entities:NSArray = NSArray(objects: kEntityName.entityList.toRaw(), kEntityName.entityItem.toRaw())
        for entity in entities {
            self.pullDataForEntity(entity as String)
        }
    }
    
    func pullDataForEntity(entity:String) {
        var query = PFQuery(className:entity)
        query.whereKey("user", equalTo:self.userDefaults.objectForKey("currentUser"))
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            
            //fetch and filter COREDATA results
            var fetchRequest:NSFetchRequest = NSFetchRequest(entityName: entity)
            if entity == kEntityName.entityList.toRaw() {
                let userPredicate:NSPredicate = NSPredicate(format: "user = %@", self.userDefaults.objectForKey("currentUser") as String)
                fetchRequest.predicate = userPredicate
            }
            var cdResults:NSArray = NSArray()
            self.coreDataManager.masterManagedObjectContext!.performBlockAndWait({
                cdResults = self.coreDataManager.masterManagedObjectContext!.executeFetchRequest(fetchRequest, error: nil)!
            })
            
            for result in cdResults {
                var index:Int = self.getIndexOfCoreDataObjectFromServer(result as NSManagedObject, serverResults: objects)
                if  index == NSNotFound {
                    //Can't Find CDObject on server : Either DELETED from server or CREATED in core data
                    if result.valueForKey("syncStatus") as NSString == kObjectSync.kObjectCreated.toRaw() {
                        //create object on server
                        self.createPFObject(entity, cdObject: result as NSManagedObject)
                        result.setValue(kObjectSync.kObjectUpdated.toRaw(), forKey: "syncStatus")
                    } else {
                        self.coreDataManager.masterManagedObjectContext?.deleteObject(result as NSManagedObject)
                    }
                } else {
                    var pfObject:PFObject = (objects as NSArray).objectAtIndex(index) as PFObject
                    if  (pfObject["updatedAt"] as NSDate).compare((result.objectForKey("updatedAt") as NSDate)) == NSComparisonResult.OrderedDescending {
                        //deleted - delete object from CD
                        //updated - replace values from CD
                        //synced - replace values from CD
                        if result.valueForKey("syncStatus") as NSString == kObjectSync.kObjectDeleted.toRaw() {
                            self.coreDataManager.masterManagedObjectContext?.deleteObject(result as NSManagedObject)
                        } else {
                            self.updateCoreDataObject(entity, pfObject: pfObject, cdObject: result as NSManagedObject)
                        }
                    } else {
                        //deleted - delete object from Server
                        //updated - replace values from Server
                        //synced - replace values from Server
                        if result.valueForKey("syncStatus") as NSString == kObjectSync.kObjectDeleted.toRaw() {
                            pfObject.deleteInBackground()
                            self.coreDataManager.masterManagedObjectContext?.deleteObject(result as NSManagedObject)
                        } else {
                            self.updatePFObject(entity, pfObject: pfObject, cdObject: result as NSManagedObject)
                        }
                    }
                }
                self.coreDataManager.saveMasterContext()
            }
            
            for object in objects {
                var index:Int = self.getIndexOfServerObjectFromCoreData(object as PFObject, coreDataResults: cdResults)
                if  index == NSNotFound {
                    self.createCoreDataObject(entity, pfObject: object)
                }
            }
        }
    }
    
    func createPFObject(entity:String, cdObject:NSManagedObject) {
        var pfCreateObject:PFObject = PFObject(className:entity)
        updatePFObject(entity, pfObject: pfCreateObject, cdObject: cdObject)
    }
    
    func updatePFObject(entity:String, pfObject:PFObject, cdObject:NSManagedObject) {
        pfObject["name"] = cdObject.valueForKey("name")
        pfObject["objectUri"] = cdObject.objectID.URIRepresentation().absoluteString!
        pfObject["isComplete"] = cdObject.valueForKey("isComplete")
        
        if entity == kEntityName.entityList.toRaw() {
            pfObject["user"] = cdObject.valueForKey("user")
            pfObject["category"] = cdObject.valueForKey("category")
            pfObject["items"] = cdObject.valueForKey("items")
        } else {
            pfObject["isFavorited"] = cdObject.valueForKey("isFavorited")
            pfObject["details"] = cdObject.valueForKey("details")
        }
        
        pfObject.saveInBackground()
    }
    
    func createCoreDataObject(entity:String, pfObject:AnyObject) {
        var cdCreateObject:NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity, inManagedObjectContext: self.coreDataManager.masterManagedObjectContext!) as NSManagedObject
        
        self.updateCoreDataObject(entity, pfObject: pfObject, cdObject: cdCreateObject)
    }
    
    func updateCoreDataObject(entity:String, pfObject:AnyObject, cdObject:NSManagedObject) {
        cdObject.setValue(pfObject["name"], forKey: "name")
        cdObject.setValue(self.formatNSDateToMatchParse(), forKey: "updatedAt")
        cdObject.setValue(pfObject["isComplete"], forKey: "isComplete")
        cdObject.setValue(pfObject["\(kObjectSync.kObjectSynced.toRaw())"], forKey: "syncStatus")
        
        if entity == kEntityName.entityList.toRaw() {
            cdObject.setValue(pfObject["user"], forKey: "user")
            cdObject.setValue(pfObject["category"], forKey: "category")
            cdObject.setValue(pfObject["items"], forKey: "items")
        } else {
            cdObject.setValue(pfObject["isFavorited"], forKey: "isFavorited")
            cdObject.setValue(pfObject["details"], forKey: "details")
        }
        
        self.coreDataManager.saveMasterContext()
    }
    
    func createList(name:String, category:String) {
        let list:List = NSEntityDescription.insertNewObjectForEntityForName(kEntityName.entityList.toRaw(), inManagedObjectContext: self.coreDataManager.masterManagedObjectContext!) as List
        
        list.user = PFUser.currentUser() != nil ? PFUser.currentUser().objectId : "anonymous"
        list.name = name
        list.category = category
        list.syncStatus = "\(kObjectSync.kObjectCreated)"
        list.updatedAt = self.formatNSDateToMatchParse()
        self.coreDataManager.saveMasterContext()
        self.sync()
    }
    
    func fetchLists() -> NSMutableArray {
        var fetchRequest:NSFetchRequest = NSFetchRequest(entityName: kEntityName.entityList.toRaw())
        let userPredicate:NSPredicate = NSPredicate(format: "user = %@", self.userDefaults.objectForKey("currentUser") as String)
        fetchRequest.predicate = userPredicate
        
        var cdResults:NSArray? = NSArray()
        self.coreDataManager.masterManagedObjectContext!.performBlockAndWait({
            cdResults = self.coreDataManager.masterManagedObjectContext!.executeFetchRequest(fetchRequest, error: nil)!
        })
        return cdResults!.mutableCopy() as NSMutableArray
    }
    
    func createItem(name:String, list:List, details:String) {
        let item:ListItem = NSEntityDescription.insertNewObjectForEntityForName(kEntityName.entityItem.toRaw(), inManagedObjectContext: self.coreDataManager.masterManagedObjectContext!) as ListItem
        
        item.name = name
        item.details = details
        item.syncStatus = "\(kObjectSync.kObjectCreated)"
        item.updatedAt = self.formatNSDateToMatchParse()
        
        list.mutableItems().addObject(item)
        
        self.coreDataManager.saveMasterContext()
        self.sync()
    }
    
// MARK: Helper Methods
    
    func getIndexOfCoreDataObjectFromServer(cdo:NSManagedObject, serverResults:NSArray!) -> Int {
        var uriArray:NSArray = (serverResults as NSArray).valueForKey("objectUri") as NSArray
        var index:Int = uriArray.indexOfObject(cdo.valueForKey("objectUri")!)
        return index
    }
    
    func getIndexOfServerObjectFromCoreData(servo:PFObject, coreDataResults:NSArray!) -> Int {
        var objectIndex:Int?
        
        for result in coreDataResults {
            if servo["objectUri"] as NSString == (result as NSManagedObject).objectID.URIRepresentation().absoluteString {
                objectIndex = coreDataResults.indexOfObject(result)
            }
        }
        
        return objectIndex!
    }
    
    func formatNSDateToMatchParse() -> NSDate {
        var now = NSDate.date()
        var calendar = NSCalendar.currentCalendar()
        var components = calendar.components((NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond), fromDate: now)
        components.hour = 0
        components.minute = 1
        components.second = 0
        var morningStart = calendar.dateFromComponents(components)
        
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var strFromDate = formatter.stringFromDate(morningStart!)
        now = formatter.dateFromString(strFromDate)
        
        return now
    }
}
