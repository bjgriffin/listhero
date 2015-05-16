//
//  DataManager.swift
//  ListHero
//
//  Created by BJ Griffin on 9/19/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit
import CoreData

enum kEntityName: String {
    case entityList = "List", entityItem = "ListItem"
}

class DataManager: NSObject {
    var coreDataManager = CoreDataManager.sharedInstance
    var lists : Array<List>?
    var currentList : List?
    let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()

    class var sharedInstance : DataManager {
        struct Static {
            static let instance = DataManager()
        }
        return Static.instance
    }
    
    //MARK: Request Methods Core Data
    
    func requestListsCD() {
        var lists = [] //Clear lists on fetch
        
        var fetchRequest:NSFetchRequest = NSFetchRequest(entityName: kEntityName.entityList.rawValue)
        let userPredicate:NSPredicate = NSPredicate(format: "user = %@", self.userDefaults.objectForKey("currentUser") as! String)
        fetchRequest.predicate = userPredicate
        
        var cdResults = Array<List>()
        
        cdResults = self.coreDataManager.masterManagedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as! Array<List>
        
        lists = cdResults
    }
    
    //MARK: Methods to call (Create)
    
    func createList(name:String, category:String) {
        PFUser.currentUser() != nil ? createListRemote(name, category: category) : createListCD(name, category: category)
    }
    
    func createItem(name:String, list:List, details:String) {
        PFUser.currentUser() != nil ? createItemRemote(name, list: list, details: details) : createItemCD(name, list: list, details: details)
    }
    
    //MARK: Create Methods Core Data

    private func createListCD(name:String, category:String) {
        let list:List = NSEntityDescription.insertNewObjectForEntityForName(kEntityName.entityList.rawValue, inManagedObjectContext: self.coreDataManager.masterManagedObjectContext!) as! List
        
        list.user = PFUser.currentUser() != nil ? PFUser.currentUser().objectId : "anonymous"
        list.name = name
        list.category = category
        list.updatedAt = self.formatNSDateToMatchParse()
        self.coreDataManager.saveMasterContext()
    }
    
    private func createItemCD(name:String, list:List, details:String) {
        let item:ListItem = NSEntityDescription.insertNewObjectForEntityForName(kEntityName.entityItem.rawValue, inManagedObjectContext: self.coreDataManager.masterManagedObjectContext!) as! ListItem
        
        item.name = name
        item.details = details
        item.updatedAt = self.formatNSDateToMatchParse()
        
        list.mutableItems().addObject(item)
        
        self.coreDataManager.saveMasterContext()
    }
    
    //MARK: Create Methods Remote Service
    
    private func createListRemote(name:String, category:String) {
        var list = PFObject(className: "List")
        list["user"] = PFUser.currentUser() != nil ? PFUser.currentUser().objectId : "anonymous"
        list["name"] = name
        list["createdAt"] = self.formatNSDateToMatchParse()
        list["updatedAt"] = self.formatNSDateToMatchParse()
        list.saveInBackgroundWithBlock({(success:Bool, error:NSError?) -> Void in
            if success {
            
            } else {
                if let error = error {
                    println(error)
                }
            }
        })
    }
    
    private func createItemRemote(name:String, list:List, details:String) {
        var item = PFObject(className: "ListItem")
        
        item["name"] = name
        item["details"] = details
        item["updatedAt"] = self.formatNSDateToMatchParse()
        
        list.mutableItems().addObject(item)
        item.saveInBackgroundWithBlock({(success:Bool, error:NSError?) -> Void in
            if success {
                
            } else {
                if let error = error {
                    println(error)
                }
            }
        })
    }

    
// MARK: Helper Methods
    
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
