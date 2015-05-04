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
    var lists : Array<List>?
    let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()

    class var sharedInstance : SyncManager {
        struct Static {
            static let instance : SyncManager = SyncManager()
        }
        return Static.instance
    }
    
    func updateDataManagerProperties() {
//        fetchUpdatedLists()
    }
    
    //MARK: Fetch Methods Core Data
    
//    func fetchUpdatedLists() {
//        var fetchRequest:NSFetchRequest = NSFetchRequest(entityName: kEntityName.entityList.rawValue)
//        let userPredicate:NSPredicate = NSPredicate(format: "user = %@", self.userDefaults.objectForKey("currentUser") as! String)
//        fetchRequest.predicate = userPredicate
//        
//        var cdResults = Array<List>()
//        self.coreDataManager.masterManagedObjectContext.performBlockAndWait({
//            cdResults = self.coreDataManager.masterManagedObjectContext!.executeFetchRequest(fetchRequest, error: nil)
//        })
//        lists = cdResults
//    }
    
    //MARK: Create Methods Core Data

    
    func createList(name:String, category:String) {
        let list:List = NSEntityDescription.insertNewObjectForEntityForName(kEntityName.entityList.rawValue, inManagedObjectContext: self.coreDataManager.masterManagedObjectContext!) as! List
        
        list.user = PFUser.currentUser() != nil ? PFUser.currentUser().objectId : "anonymous"
        list.name = name
        list.category = category
        list.syncStatus = "\(kObjectSync.kObjectCreated)"
        list.updatedAt = self.formatNSDateToMatchParse()
        self.coreDataManager.saveMasterContext()
    }
    
    func createItem(name:String, list:List, details:String) {
        let item:ListItem = NSEntityDescription.insertNewObjectForEntityForName(kEntityName.entityItem.rawValue, inManagedObjectContext: self.coreDataManager.masterManagedObjectContext!) as! ListItem
        
        item.name = name
        item.details = details
        item.syncStatus = "\(kObjectSync.kObjectCreated)"
        item.updatedAt = self.formatNSDateToMatchParse()
        
        list.mutableItems().addObject(item)
        
        self.coreDataManager.saveMasterContext()
    }
    
// MARK: Helper Methods
    
    func getIndexOfCoreDataObjectFromServer(cdo:NSManagedObject, serverResults:NSArray!) -> Int {
        var uriArray:NSArray = (serverResults as NSArray).valueForKey("objectUri") as! NSArray
        var index:Int = uriArray.indexOfObject(cdo.valueForKey("objectUri")!)
        return index
    }
    
    func getIndexOfServerObjectFromCoreData(servo:PFObject, coreDataResults:NSArray!) -> Int {
        var objectIndex:Int?
        
        for result in coreDataResults {
            if servo["objectUri"] as? NSString == (result as! NSManagedObject).objectID.URIRepresentation().absoluteString {
                objectIndex = coreDataResults.indexOfObject(result)
            }
        }
        
        return objectIndex!
    }
    
    func formatNSDateToMatchParse() -> NSDate {
        var now = NSDate()
        var calendar = NSCalendar.currentCalendar()
        var components = calendar.components((NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond), fromDate: now)
        components.hour = 0
        components.minute = 1
        components.second = 0
        var morningStart = calendar.dateFromComponents(components)
        
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var strFromDate = formatter.stringFromDate(morningStart!)
        now = formatter.dateFromString(strFromDate)!
        
        return now
    }
}
